---
layout: post
title:  "Subversion リポジトリの同期設定"
date:   2009-06-12 16:56:13
category: server
tags: subversion
---

## svnsync でリポジトリの同期

Subversion 1.4以降でないと使えないらしい。

### 同期先のリポジトリ準備

空のリポジトリを作成する。パーミッションは適宜設定すれば良い。

```sh
svnadmin create /home/svn/backup
```

### フックの設定

リポジトリの /hooks に設定を追加する。

```sh
cd /home/svn/backup/hooks
cp pre-revprop-change.tmpl pre-revprop-change
chmod +x pre-revprop-change
```

#### pre-revprop-change の設定

以下の内容で保存する。

```sh
#!/bin/sh
exit 0
```

### svnsync の実行

初期化には `init` タスクを実行する。

```sh
svnsync init file:///home/svn/backup svn+ssh://hoge@repos.exsample.com/home/svn/original
```

一度初期化したら以下のコマンドで同期出来る。

```sh
svnsync sync file:///home/svn/backup
```

あとはCron などで定期的に `sync` タスクを実行すればOK.

