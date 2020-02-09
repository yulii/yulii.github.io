---
layout: post
title:  "Haskell 製 WebフレームワークYesod はじめました"
date:   2013-10-25T13:03:12+0900
category: engineering
tags: haskell yesod
---

## Yesod の環境準備

インストールから動かし方まで。

```sh
brew install haskell-platform
```

Haskell を入れると、`cabal` コマンドが使える。Bundler や Maven みたいなにモジュール管理できる。

```sh
cabal update
```

### Yesod のインストール

結構、時間がかかります。

```sh
cabal install yesod-platform
cabal install yesod-bin
```

### Yesod アプリケーションの作成と実行

アプリケーションの作成は

```sh
yesod init
```

アプリケーションの実行は

```sh
yesod devel
```

で、http://localhost:3000/ から確認できる。

## Yesod アプリケーションの GHCi コンソール

コンソールを叩く方法 (`rails console` 的なやつ)

```sh
cabal install cabal-dev
cabal-dev ghci
```

Yesod 関連のモジュールを読み込んだ状態で GHCi が起動する。
`import Import` すれば、Model やHandler などを使って実行できる。
