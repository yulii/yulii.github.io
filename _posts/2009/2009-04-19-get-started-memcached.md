---
layout: post
title:  "オンメモリKVS のmemcached の使い方"
date:   2009-04-19T12:30:21+0900
category: engineering
tags: server memcached
---

## memcached とは？

- 分散メモリキャッシュシステム (Distributed Memory object Caching System)
- レコード (value) とキー (key) のペアをメモリ上で管理
- メモリを超えるとLRU (Least Recently Used) に従って古いデータが消える
- シンプルなテキストプロトコル
- サーバ側ではなく，クライアント側で分散を行う
- memcached 自体に分散機能は実装されていない

### memcached のインストール

memcached は libev ではなく libevent を使っているらしい。

```sh
sudo apt-get install libevent1 libevent-dev
```

libevent を入れた後，memcached をインストールする。

```sh
wget http://www.danga.com/memcached/dist/memcached-1.2.6.tar.gz
tar zxvf memcached-1.2.6.tar.gz
cd memcached-1.2.6
./configure
make
sudo make install
```

#### gcc 関連のエラー対処

gcc がインストールされていない場合、以下のようなエラーが出るので別途インストール (`sudo apt-get install gcc`) をする。

```
checking build system type...
Invalid configuration `i686-pc-linux-oldld': machine `i686-pc-linux' not recognized
```


### memcached の起動と使い方

`memcached` コマンドのオプションは以下の通り。

- -u ユーザの指定
- -p ポートの指定 (デフォルト: 11211)
- -m 使用するメモリの容量[MB]
- -d バックグラウンド起動

#### フォアグラウンド

```sh
memcached -p 11211 -m 64 -vv
```

#### バックグラウンド (デーモン)

```sh
memcached -p 11211 -m 64 -d
```

### 接続 (telnet) テスト

`telnet` コマンドで起動した memcached へ通信できるかテストする。

```sh
$ telnet 127.0.0.1 11211
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
stats
STAT pid 16719
STAT uptime 15858
STAT time 1236271454
STAT version 1.2.6
STAT pointer_size 32
STAT rusage_user 0.000000
STAT rusage_system 1.570000
STAT curr_items 1
STAT total_items 3
STAT bytes 63
STAT curr_connections 2
STAT total_connections 5
STAT connection_structures 3
STAT cmd_get 3
STAT cmd_set 5
STAT get_hits 3
STAT get_misses 0
STAT evictions 0
STAT bytes_read 230
STAT bytes_written 693
STAT limit_maxbytes 67108864
STAT threads 1
END
quit
Connection closed by foreign host.
```

memcached 側の出力はこんな感じ。

```sh
$ memcached -p 11211 -m 64m -vv
<6 server listening
<7 send buffer was 110592, now 268435456
<7 server listening (udp)

<8 new client connection
<8 stats
>8 STAT pid 16719
STAT uptime 15858
STAT time 1236271454
STAT version 1.2.6
STAT pointer_size 32
STAT rusage_user 0.000000
STAT rusage_system 1.570000
STAT curr_items 1
STAT total_items 3
STAT bytes 63
STAT curr_connections 2
STAT total_connections 5
STAT connection_structures 3
STAT cmd_get 3
STAT cmd_set 5
STAT get_hits 3
STAT get_misses 0
STAT evictions 0
STAT bytes_read 230
STAT bytes_written 693
STAT limit_maxbytes 67108864
STAT threads 1
END
<8 quit
<8 connection closed.
```

### memcached のコマンド

問い合わせの形式は以下の通り。

#### SET (保存)

```
set <key> <flags> <exptime> <bytes>
<data>
```

#### GET (取得)

```
get <key>
```

#### SET したデータを GET する例

```sh
$ telnet localhost 11211
Trying 127.0.0.1…
Connected to localhost.localdomain (127.0.0.1).
Escape character is ‘^]’.
set key 0 0 5
value
STORED
get key
VALUE key 0 5
value
```
