---
layout: post
title:  "うっかりさんのための Cabal Hell プロテクター"
date:   2014-09-06 13:21:30 UTC+9
category: haskell
---

Haskell を使うときは Cabal だよね。でも、`cabal` でパッケージをインストールするときに、依存の解消がイマイチでハマりがち。

そして、たまにしか Haskell を触らないので、ついうっかり Cabal Hell に迷い込んでしまう俺。

## Cabal Hell とは
新しいパッケージをインストールするために何気なく `cabal install` をした結果、インストール済みの既存パッケージをぶっ壊してしまう恐ろしい現象を指すHaskeller 用語である。その後、なぞのインストールエラーに悩まされ、エラーメッセージを読み解き、問題を解消しようと試みるとエラーが出続けて終わりが見えない状況に陥る。


何はともあれ、プロジェクトごとに `cabal sandbox init` しておくと幸せになれます。

## cabal update トラップ

Haskell Platform をインストールした後、`cabal update` でパッケージ一覧の情報を取得する必要がある。
黒い画面を眺めていると下記のようなメッセージが出力される。

~~~
Config file path source is default config file.
Config file /Users/yulii/.cabal/config not found.
Writing default configuration to /Users/yulii/.cabal/config
Downloading the latest package list from hackage.haskell.org
Note: there is a new version of cabal-install available.
To upgrade, run: cabal install cabal-install

~~~


「新しいバージョンの `cabal-install` があるよ！`cabal install cabal-install` しちゃいなよ。」と言われるので、言われた通り `cabal install cabal-install` を黒い画面に打ち込むと Welcome to cabal hell! するという罠。


### 発生環境

- Mac OS X 10.9.4
- haskell-platform-2013.2.0.0_1
- cabal-install version 1.16.0.2


ちなみに、Haskell Platform は `brew haskell-platform` で入れてる。


## うっかりミスしちゃう俺のための cabal コマンド

`.bash_profile` で `cabal` コマンドをラップしてみた。

~~~sh
cabal() {
  if [ $# -ge 2 ] && [ "$1" = "install" ]; then
    if expr $2 : "^cabal-install.*$" > /dev/null; then
      echo "Seriously? Don't freak out! ...Are you sure?"
      printf "run \`cabal %s\`? [y/N]: " "$*"
      read ANSWER
      ANSWER=`echo $ANSWER | tr "[:upper:]" "[:lower:]"`
      if ! expr $ANSWER : "^[y|yes]$" > /dev/null; then
        return 1
      fi
    fi
  fi
  /usr/local/bin/cabal $@
}

~~~

これで、`cabal install cabal-install` するときに確認してくれます。Happy Haskelling and Happy Holidays!

