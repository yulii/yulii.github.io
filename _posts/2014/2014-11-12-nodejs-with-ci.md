---
layout: post
title:  "Travis CI + Coverall + Node.js (Hubot) で継続的インテグレーションしてみる"
date:   2014-11-12 17:02:15
category: javascript
tags: nodejs hubot ci
---

Hubot スクリプトのために、CI 環境を整えてみた。説明用にコードを切り出したりしているので、全体の設定は今回使っている [libinc/hubot-scripts](https://github.com/libinc/hubot-scripts) を見てください。

## 継続的インテグレーション (Continuous Integration) ツール

- [GitHub](https://github.com)
- [Travis CI](https://travis-ci.org)
    - テスト実行には [mocha](https://www.npmjs.org/package/mocha) を利用
- [Coveralls](https://coveralls.io)
    - カバレッジ測定には [blanket](https://www.npmjs.org/package/blanket) を利用
- [David.](https://david-dm.org)

## テストコード

テスト実行には

- chai
- mocha
- hubot-mock-adapter

を利用しています。Hubot スクリプトは CoffeeScript で書いているので、mocha の設定 `test/mocha.opts` は以下の様に定義してます。

```
--compilers coffee:coffee-script/register
--recursive
```

テストコードは綺麗に整理できていないので、詳細については割愛。

## Travis CI

オープンソースで良く利用されている。公開リポジトリなら無料で使える。

### GitHub との連携

Travis にGitHub アカウントでログインして、リポジトリを選ぶだけ。連携後はGitHub にPush すると自動でフックしてテストを実行してくれる。Node の場合、テストの実行は `npm test` が実行される。細かい設定はプロジェクトのROOT ディレクトリ直下においた `.travis.yml` に記述する。

```ruby
language: node_js
node_js:
  - 0.10
```

Node のバージョンは複数指定できるので、一括でバージョン対応をチェックできる。


## Coveralls

テストカバレッジ計測のデータを集計してくれる。

### インストール

Coveralls へのレポート作成用に必要な物を追加する。

```
npm install coveralls --save-dev
npm install mocha-lcov-reporter --save-dev
```

## blanket

テストカバレッジの測定をしてくれるライブラリ。CoffeeScript にも対応しています。

```
npm install blanket --save-dev
```

設定は `package.json` に記述する。

```
"config": {
  "blanket": {
    "pattern": [
      "hubot-scripts/scripts",
      "hubot-scripts/module"
    ],
    "loader": "./node-loaders/coffee-script",
    "data-cover-never": "node_modules"
  }
}
```

`pattern` には計測対象のテストファイルを指定する。ただし、絶対パス (プロジェクトではなくシステムのROOT からのパス) に対してマッチング判定される。

### カバレッジ測定用のスクリプト

Makefile で定義しているサンプルは見かけたけど、設定を `package.json` 内にまとめたかったので、下記の様に scripts を追加した。

```
"scripts": {
  "test": "mocha",
  "coveralls": "mocha test --require blanket --reporter mocha-lcov-reporter | coveralls"
}
```

これで `npm run-script coveralls` を実行すると、テストカバレッジを計測して、結果をCoveralls へ送信してくれます。


### Travis との連携

Travis CI 内でテスト実行時の環境変数を設定する。`.travis.yml` ではなく、サイト内の設定画面で追加する。

```
COVERALLS_SERVICE_NAME=travis-ci
COVERALLS_REPO_TOKEN=%Coverall で発行されたトークン%
```

環境変数を設定するとテスト実行前に `export` してくれます。cf. [libinc/hubot-scripts Build #5](https://travis-ci.org/libinc/hubot-scripts/builds/40147672)


Coveralls へのレポートは package.json で `npm run-script coveralls` コマンドを定義したので、Travis CI から実行させる。

```ruby
after_success:
  - npm run-script coveralls
```

冗長だけど手元では Coveralls 通知なしでテスト実行したいので、デフォルトの `npm test` はカバレッジ計測しない形にした。


## David.

依存ライブラリのバージョンをチェックしてくれる。古いバージョンを参照していると警告してくれる。cf. [Hubot の依存ライブラリ](https://david-dm.org/github/hubot)

特に設定はいらないので、サイトの説明通りリポジトリのパスを指定してバッチを付けておくだけ。


```
![Dependencies Status](https://david-dm.org/username/repo.png)
```

## まとめ

こんな感じで、CI モニタリングできます。

[![Build Status](https://api.travis-ci.org/libinc/hubot-scripts.png)](https://travis-ci.org/libinc/hubot-scripts)
[![Coverage Status](https://img.shields.io/coveralls/libinc/hubot-scripts.svg)](https://coveralls.io/r/libinc/hubot-scripts?branch=master)
[![Dependencies Status](https://david-dm.org/libinc/hubot-scripts.png)](https://david-dm.org/libinc/hubot-scripts)

