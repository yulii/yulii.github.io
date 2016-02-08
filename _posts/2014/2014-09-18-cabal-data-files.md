---
layout: post
title:  "Cabal パッケージに外部ファイルを埋め込む"
date:   2014-09-18 17:53:23 UTC+9
category: haskell
---

Cabal パッケージで実行時に必要な外部ファイル埋め込む方法について

## Cabal パッケージの設定

pkgname.cabal で `data-files` もしくは `data-dir` を指定する。`data-files` はワイルドカード指定できるので `data-files: images/*.png` などまとめてファイル指定も可能。

## 実装方法

`data-files` のフルパスを取得する関数が用意されている

~~~
getDataFileName :: FilePath -> IO FilePath
~~~

利用するときは `import Paths_pkgname` する必要がある

~~~
import Paths_pkgname
import qualified Data.ByteString.Lazy.Char8 as BS

getContent = do
  fp <- getDataFileName "data/hoge.txt"
  content <- BS.readFile fp
  return content
~~~

参考) _[Accessing data files from package code](http://www.haskell.org/cabal/users-guide/developing-packages.html#accessing-data-files-from-package-code)_

