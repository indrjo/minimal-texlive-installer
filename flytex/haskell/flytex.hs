#!/usr/bin/env runghc

-- As you can see from the list of imports below, there are few modules the
-- program requires to work properly.
--
-- !!! Write an appropriate .cabal file.
-- !!! In *.cabal specify:
-- !!!  base, process, options, regex-pcre
-- !!!
-- !!! No particular version?

import Data.List (find, isPrefixOf, isSuffixOf)
import Data.List.Extra (trim)
import Text.Regex.PCRE((=~))
import System.Process (readCreateProcessWithExitCode, shell)
import System.Exit (ExitCode(..))
import System.Directory (doesFileExist)
import System.IO (hPutStrLn, stdout, stderr, Handle)
import Options

-- ------------------------------------------------------------------------
-- 0. THE MAIN
-- ------------------------------------------------------------------------

-- Starting in medias res, the main amounts at two big pieces: one is the 
-- function flytex and the other is makeTeXCommand. Roughly speaking, the 
-- latter is the command to be issued to the host system, whereas the first
-- is the core of the program: while texing, needed but abset packages are
-- installed "on the fly".
main :: IO ()
main = makeTeXCommand >>=
  either flytexSaysError flytex


-- ------------------------------------------------------------------------
-- 1. MAKE THE UNDERLYING SYSTEM DO THINGS
-- ------------------------------------------------------------------------

-- There ought be no surprise if we say this program intimately relies on
-- the OS that hosts this program. Our ideal user, as we have already said,
-- is a GNU/Linux user, or even a *nix one.

-- Thus we need a function that sends commands to the system and makes them
-- run. This function is a mere combination of a couple of functions from 
-- System.Process and the return type slightly changed: take a string as
-- input, which is assumed to be a shell command, and make the underlying 
-- system run it.
exec :: String -> String -> IO (ExitCode, String, String)
exec cmd inp =
  fmap (\(a, b, c) -> (a, trim b, trim c)) $
    readCreateProcessWithExitCode (shell cmd) inp
-- !!! By its nature, the function readCreateProcessWithExitCode evaluates 
-- !!! strictly the components of the return triple. Is this a problem?

-- For the future, it s best we use the following functions, which wraps
-- the previous one.
flytexExec:: String -> String -> IO (ExitCode, String, String)
flytexExec cmd inp =
  flytexSays ("running \'" ++ cmd ++ "\'...") >> exec cmd inp

-- !!! About `flytexExec`... Why not the variant below? The clear advantage
-- !!! is that you can decide what to say just before a command is run.
--flytexExec:: String -> String -> String -> IO (ExitCode, String, String)
--flytexExec intro cmd inp = flytexSays intro >> exec cmd inp


-- ------------------------------------------------------------------------
-- 2. INVOKING TLMGR
-- ------------------------------------------------------------------------

-- A minimal TeX Live has tlmgr who handles packages: not only you install
-- packages with it, but you can search packages containing a given file!
-- They are both interesting for our purpose.

-- Installing packages is the simpler part here, you just have to type
--
--  $ tlmgr install <pkg>
--
-- and wait tlmgr to end.
tlmgrInstall :: String -> IO (Either String String)
tlmgrInstall pkg =
  flytexExec ("tlmgr install " ++ pkg) "" >>=
    -- Among the outputs, just take the exit code: either the installation
    -- has ended successfully or it hasn't. Right?
    \(exit_code, _, _) ->
      -- Just return Left or Right strings, that will be printed for info.
      return $ case exit_code of
        ExitSuccess   -> Right $ "installed \'" ++ pkg ++ "\'"
        ExitFailure _ -> Left  $ "cannot install \'" ++ pkg ++ "\'!"
      -- !!! In case of failure, attach the log too?

-- It is best we provide a function to perform multiple installations. For
-- a list of packages corresponding to a given missing file, install them
-- one by one; just stop with a Left message as one cannot be installed.
tlmgrMultipleInstall :: String -> [String] -> IO (Either String String)
tlmgrMultipleInstall fp [] =
  return $ Right $ "all missing packages for " ++ fp ++ " installed"
tlmgrMultipleInstall fp (pkg:pkgs) =
  tlmgrInstall pkg >>=
    either
      (return . Left)
      (\out -> tlmgrSays out >> tlmgrMultipleInstall fp pkgs)

-- Let us turn our focus on searching packages now. To do so, let us start
-- from a descriptive example.
--
-- | $ tlmgr search --global --file caption.sty
-- | tlmgr: package repository [...]
-- | caption:
-- | 	 texmf-dist/tex/latex/caption/bicaption.sty
-- | 	 texmf-dist/tex/latex/caption/caption.sty
-- | 	 texmf-dist/tex/latex/caption/ltcaption.sty
-- | 	 texmf-dist/tex/latex/caption/subcaption.sty
-- | ccaption:
-- | 	 texmf-dist/tex/latex/ccaption/ccaption.sty
-- | lwarp:
-- | 	 texmf-dist/tex/latex/lwarp/lwarp-caption.sty
-- | 	 texmf-dist/tex/latex/lwarp/lwarp-ltcaption.sty
-- | 	 texmf-dist/tex/latex/lwarp/lwarp-mcaption.sty
-- | 	 texmf-dist/tex/latex/lwarp/lwarp-subcaption.sty
-- | mcaption:
-- | 	 texmf-dist/tex/latex/mcaption/mcaption.sty
--
-- The first line just tells the repository interrogated, we cannot do not
-- care here. The other lines are the ones very interesting: there is a
-- sequence of
-- 
--  package:
--    path1
--    path2
--    ...
--    pathN
--
-- In our example, the paths end with `caption.sty`. In this case, we are
-- looking for exactly `caption.sty` and not for, say, `ccaption.sty`. This
-- problem can be easily solved putting a "/", as follows:
--
-- | $ tlmgr search --global --file /caption.sty
-- | tlmgr: package repository [...]
-- | caption:
-- | 	 texmf-dist/tex/latex/caption/caption.sty
--
-- Thus part of the work is to extract from such lines only the names of 
-- the packages containing the given file: concretely, this means to filter
-- the lines ending with ":".
findPackages :: [String] -> [String]
findPackages = map init . filter (isSuffixOf ":")

-- Make tlmgr look for packages containing the given file.
tlmgrSearch :: String -> IO (Either String (Maybe [String]))
tlmgrSearch fp =
    flytexExec ("tlmgr search --global --file /" ++ fp) "" >>=
      \(exit_code, out_str, err_str) ->
        return $ case exit_code of
          ExitSuccess ->
          -- In case of exit code equal to 0, get rid of the first line of
          -- the standard output (see the example above) and scrape the
          -- remaining lines if there are some.
            Right $ case lines out_str of
              _:out_lns' ->
                (\xs -> if null xs then Nothing else Just xs)
                  (findPackages out_lns')
              _ -> Nothing
          -- Otherwise, just collect all the error message, to be presented
          -- to the user in future.
          ExitFailure _ -> Left $ err_str

-- Now, let us combine the tasks above into one: search and install all the
-- packages containing a given file.
tlmgrSearchAndInstall :: String -> IO (Either String String)
tlmgrSearchAndInstall fp =
  tlmgrSearch fp >>=
    either
      (return . Left)
      (maybe
        (return . Left $ "no package containing \'" ++ fp ++ "\'!" )
        (tlmgrMultipleInstall fp))


-- ------------------------------------------------------------------------
-- 3. PREPARE THE COMMAND TO BE RUN
-- ------------------------------------------------------------------------

-- For future readability and changes, let us take advantage of unnecessary
-- type synonyms.
type TeXProgram = String   -- the path of the TeX binary to be invoked
type TeXOptions = String   -- the options passed to the program above
type FileToTeX  = String   -- the *.tex all the preceding stuff applies  

-- Here the command to issue to the system with its Show instance.
data TeXCommand = TeXCommand TeXProgram TeXOptions FileToTeX

instance Show TeXCommand where
  show (TeXCommand prog opts fp) =
    unwords $ if null opts then [prog, fp] else [prog, opts, fp]

-- This is the point where commandline arguments enters the scene.
-- This program supports only three options:
--
--   # the TeX program to be used     [mandatory, no default!]
--   # the options to be passed to it [default: ""]
--   # the file to be TeX-ed.         [mandatory, of course]
--
-- For the future: maybe insert more useful defaults here.

-- Options for flytex...
data MainOptions = MainOptions
  {
      optTeXProgram :: Maybe FilePath
    , optTeXOptions :: String
    , optTeXFile    :: Maybe FilePath
  }

instance Options MainOptions where
  defineOptions = pure MainOptions
    <*> simpleOption "c" Nothing
          "indicate the TeX engine you intend to use"
    <*> simpleOption "o" ""
          "option to pass to the TeX engine [default: \"\"]"
    <*> simpleOption "i" Nothing
          "the file you want to be TeX-ed"

getTeXProgram :: IO (Maybe FilePath)
getTeXProgram = option optTeXProgram

getTeXOptions :: IO String
getTeXOptions = option optTeXOptions

getTeXFile :: IO (Maybe FilePath)
getTeXFile = option optTeXFile

option :: Options o => (o -> a) -> IO a
option f = runCommand $ \opts _ -> return (f opts)

-- Read the command line options passed to the program and either create a
-- TeXCommand to be issued to the system or present a complaint.
makeTeXCommand :: IO (Either String TeXCommand)
makeTeXCommand =
  getTeXProgram >>=
    maybe (return $ Left "No TeX program provided!")
      (\program ->
        getTeXOptions >>=
          \options ->
            getTeXFile >>=
              maybe (return $ Left "No file to TeX provided!")
                (\path ->
                  controlsOnTeXCommand
                    (TeXCommand program options path)))

-- A series of controls to do during the creation of a TeXCommand element:
-- check if the program is in PATH and if the file to TeX exists.
controlsOnTeXCommand :: TeXCommand -> IO (Either String TeXCommand)
controlsOnTeXCommand tex_cmd@(TeXCommand prog _ fp) =
  exec ("which " ++ prog) "" >>=
    \(exit_code, _, _) ->
      case exit_code of
        ExitSuccess ->
          doesFileExist fp >>=
            return . \yes ->
              if yes
                then Right tex_cmd
                else Left (fp ++ " does not exist!")
        ExitFailure _ ->
          return (Left $ prog ++ "not found!")


-- ------------------------------------------------------------------------
-- 4. TEXLIVE ON THE FLY
-- ------------------------------------------------------------------------

-- This giant function takes a TeXCommand element and make the underlying 
-- system run it. If no error arises, fine; otherwise, the program tries to
-- detect missing files, looks for missing packages containing it and
-- installs them; thus, a new attempt to run the same TeXCommand is made.
flytex :: TeXCommand -> IO ()
flytex tex_cmd =
  flytexExec (show tex_cmd) "X" >>=
    -- !!! Here the third component isn't taken into account: it seems
    -- !!! tlmgr prints everything to standard output, thus there should
    -- !!! occur no problem here.
    \(exit_code, out_str, _) ->
      case exit_code of
        -- If the command terminates with success, there is nothing to do
        -- other than to to say everything is fine!
        ExitSuccess ->
          flytexSays $ "\'" ++ show tex_cmd ++ "\': done"
        -- Of course, the core of flytex is how it hnadles the failure.
        ExitFailure _ ->
          -- First fo all, look for the line containing the error. (La)TeX
          -- errors are lines starting with "!", so they are quite simple
          -- to locate.
          case find (isPrefixOf "!") (lines out_str) of
            -- !!! The program should not arrive at this point, but ghc may
            -- !!! complain if all not cases are not covered.
            Nothing -> undefined
            -- Of course, this program can't handle every error may arise.
            -- If the error says that one file is missing, then it is bread
            -- for flytex.
            Just tex_err ->
              case findMissings tex_err of
                -- Once the name of the missing file is properly isolated
                -- (see the implementation of findMissings), install any
                -- package containing it. Observe that this kind of errors 
                -- indicate one missing file per time, hence you should 
                -- expect a list with at most one element. 
                fp:_ ->
                  tlmgrSearchAndInstall fp >>=
                    either
                      (\left_str ->
                        tlmgrSaysError left_str)
                      (\right_str ->
                        tlmgrSays right_str >> flytex tex_cmd)
                -- !!! It is a nice thing to present to users any error 
                -- !!! flytex cannot handle. With time, maybe they may 
                -- !!! suggest finer features for flytex. 
                _ -> flytexSaysError tex_err

-- Inspect a string for a certain pattern to get the name of the missing
-- package. The output is always a list with length <=1.
findMissings :: String -> [String]
findMissings =
    flip findAllMatches "! (?:La)*TeX Error: File `([^\']+)\' not found."
  where
    -- List all matches in a string.
    findAllMatches :: String -> String -> [String]
    findAllMatches string pattern =
      (\(_, _, _, matches) -> matches)
        (string =~ pattern :: (String, String, String, [String]))


-- ------------------------------------------------------------------------
-- 5. HOW THE PROGRAM COMMUNICATES
-- ------------------------------------------------------------------------

-- !!! No fatal massages here, that is no message will abort the execution
-- !!! of flytex. This feature may change or not, but for now that's it.

-- The general way, to say things.
say :: Handle -> String -> String -> IO ()
say hdl who txt = hPutStrLn hdl $ "[" ++ who ++ "] " ++ txt

flytexSays, flytexSaysError :: String -> IO ()
flytexSays      = say stdout "flytex"
flytexSaysError = say stderr "flytex-error"

tlmgrSays, tlmgrSaysError :: String -> IO ()
tlmgrSays      = say stdout "tlmgr"
tlmgrSaysError = say stderr "tlmgr-error"

