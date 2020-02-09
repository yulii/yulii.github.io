---
layout: post
title:  "Mac で Cabal Sandbox 環境を整える"
date:   2014-09-11T08:40:30+0900
category: engineering
tags: haskell
---

Cabal Hell を回避するためのSandbox 環境を整えたときのメモ。

## Cabal Sandbox

`cabal-install-1.18` から Sandbox 環境が使える。プロジェクトごとに `.cabal-sandbox/` ディレクトリを作って依存ライブラリを管理してくれる。

## Mac OX での環境構築

Homebrew でHaskell-Platform を入れているが、Cabal のバージョンが 1.16 なので、Sandbox に対応していない。まずは、`cabal-install` の最新バージョンをインストールする。

```
cabal install cabal-install
```

`cabal install` しただけだと、古いバージョンが参照されるので使えない。以下のような状態になっている。

```
$ cabal sandbox init
cabal: unrecognised command: sandbox (try --help)

$ cabal --version
cabal-install version 1.16.0.2
using version 1.16.0 of the Cabal library

$ ~/.cabal/bin/cabal --version
cabal-install version 1.20.0.3
using version 1.20.0.2 of the Cabal library
```

参考) _[cabal: unrecognised command: sandbox (try --help) #38](https://github.com/jetaggart/light-haskell/issues/31#issuecomment-34576598)_

`$HOME/.cabal/` 配下にインストールされるため、バイナリファイルを`PATH` が通っている別の場所に移動する。面倒なので Homebrew で入れたファイルを上書きした。

```
cp $HOME/.cabal/bin/cabal /usr/local/bin/cabal
```

あとは、Cabal プロジェクトごとに `cabal sandbox init` をすればOK.


## Cabal Hell の対処方法

### Sandbox がない場合

ホームディレクトリに依存ライブラリのデータが保存されているので、サクッと削除する。


```
rm -rf ~/.ghc/ ~/.cabal/

```

共通で使っているとすべてのプロジェクトに影響するので注意。注意と言っても大抵にっちもさっちも行かない状態なので、`rm -rf` するしか無いけど・・・。そして、削除後は `cabal update` からやり直す。


### Sandbox がある場合

対象のSandbox を削除して作り直すだけでOK.

```
cabal sandbox delete
cabal sandbox init

cabal install —only-dependencies
cabal configure
```
