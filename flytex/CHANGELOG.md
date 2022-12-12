
# History of flytex

## Issues present in all the ```flytex```-es here...

### [3 dec 2022] More paths for one package

```
$ tlmgr search --global --file caption.sty
tlmgr: package repository [...]
caption:
	texmf-dist/tex/latex/caption/bicaption.sty
	texmf-dist/tex/latex/caption/caption.sty
	texmf-dist/tex/latex/caption/ltcaption.sty
	texmf-dist/tex/latex/caption/subcaption.sty
ccaption:
	texmf-dist/tex/latex/ccaption/ccaption.sty
lwarp:
	texmf-dist/tex/latex/lwarp/lwarp-caption.sty
	texmf-dist/tex/latex/lwarp/lwarp-ltcaption.sty
	texmf-dist/tex/latex/lwarp/lwarp-mcaption.sty
	texmf-dist/tex/latex/lwarp/lwarp-subcaption.sty
mcaption:
	texmf-dist/tex/latex/mcaption/mcaption.sty
```

Here, the program cannot isolate ```caption```. Another example: in

```
$ tlmgr search --global --file pgf.sty
tlmgr: package repository https://ctan.mirror.garr.it/mirrors/ctan/systems/texlive/tlnet (verified)
chessboard:
	texmf-dist/tex/latex/chessboard/chessboard-keys-pgf.sty
	texmf-dist/tex/latex/chessboard/chessboard-pgf.sty
pgf:
	texmf-dist/tex/latex/pgf/basiclayer/pgf.sty
storebox:
	texmf-dist/tex/latex/storebox/storebox-pgf.sty
```

we cannot isolate ```pgf```.

Possible patch:

In the Haskell version:

```haskell
findPackages :: String -> [String] -> [String]
findPackages fp (ln1:ln2:lns) =
  case ln2 of
    '\t':_ ->
      if isSuffixOf ('/':fp) ln2
        then (init ln1) : findPackages fp (dropWhile (isPrefixOf "\t") lns)
        else findPackages fp (ln1:lns)
    _:_ -> findPackages fp (ln2:lns)
    _ -> undefined -- this should not happen
findPackages _ _ = []
```

instead of:

```haskell
findPackages :: String -> [String] -> [String]
findPackages fp (pkg:path:other) =
  if ('/':fp) `isSuffixOf` path
    then (init pkg) : findPackages fp other
    else findPackages fp other
findPackages _ _ = []
```

In the Python version: temporary patched too. (See source code)

