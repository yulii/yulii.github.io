---
layout: post
title:  "匿名プロキシ Tor の導入方法"
date:   2009-06-16 11:15:29 UTC+9
category: network
---

## 匿名プロキシ Tor (オニオンルーティング)

### Tor のインストール

Tor 用のユーザとグループをあらかじめ作成して、インストール時に設定する。

#### Tor のインストールに必要なライブラリ

- Zlib
- OpenSSL
- libevent

以下のコマンドでインストールを実行する。

```sh
./configure --with-tor-user=tor --with-tor-group=tor
make
make install
```
`--with-libevent-dir=libevent` で libevent ディレクトリを指定した方が良いかもしれない。


#### Tor のデータ処理用のディレクトリを作成

適当な場所に専用のディレクトリを作成し、所有権限を設定する。

```sh
mkdir /var/run/tor
chown tor:tor /var/run/tor
```

### ブラウザで利用する

ブラウザで使うためには Privoxy を入れる。(DNS リクエストの匿名性)

```sh
autoheader && autoconf
./configure --with-user=privoxy --with-group=privoxy
make
make install
```

