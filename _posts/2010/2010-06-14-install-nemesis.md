---
layout: post
title:  "パケット生成ツール nemesis のインストール"
date:   2010-06-14T10:34:46+0900
category: engineering
tags: network
---

## nemesis

コマンドラインからカスタマイズしたパケットを生成できるツールです。DoS 攻撃のパケットも作れてしまうので、意図せず攻撃パケットを外部サーバーへ送信しないように取り扱い注意です。

### インストール@CentOS5.5

依存モジュールは以下の2つ

- libnet-1.0.2a
- gcc

#### libnet インストール

ソースからインストールする。

```sh
cd /usr/local/src
wget ftp://ftp.ru/pub/sunfreeware/SOURCES/libnet-1.0.2a.tar.gz
tar xzvf libnet-1.0.2a.tar.gz
cd Libnet-1.0.2a
./configure
make
make install
```

#### nemesis 本体インストール

こちらもソースからインストールする。

```sh
cd /usr/local/src
wget http://prdownloads.sourceforge.net/nemesis/nemesis-1.4.tar.gz?download
cd nemesis-1.4
./configure
make
make install
```
