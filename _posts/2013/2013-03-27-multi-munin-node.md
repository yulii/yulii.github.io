---
layout: post
title:  "Munin ではじめる複数台構成のサーバ監視"
date:   2013-03-27 15:53:14 UTC+9
category: engineering
tags: server munin supervision
---

## 複数台のサーバをまとめてリソース監視

インストールとか、起動とか、Munin 出力結果を表示するWeb サーバーの設定は割愛

### 監視ノード (munin-node) の設定

リソース監視したいサーバーの設定は、`host_name`, `allow`, `host *` の3つを設定するだけ。

#### /etc/munin/munin-node.conf

```sh
log_level 4
log_file /var/log/munin/munin-node.log
pid_file /var/run/munin/munin-node.pid

background 1
setsid 1

user root
group root

# Regexps for files to ignore
ignore_file [\#~]$
ignore_file DEADJOE$
ignore_file \.bak$
ignore_file %$
ignore_file \.dpkg-(tmp|new|old|dist)$
ignore_file \.rpm(save|new)$
ignore_file \.pod$

host_name yulii.net # 監視ノード名

allow ^127\.0\.0\.1$
allow ^192\.168\.0\.100$ # Munin サーバーの IP を追加

host * # Munin サーバーで集計データが受け取れるようにする

port 4949
```

host の設定が解放されていないと、集計データが Munin サーバーで取得できない。

`host 127.0.0.1` を設定した場合に、Munin サーバー側から接続を確認すると、

```sh
$ nmap 192.168.0.100 -p 4949
PORT      STATE  SERVICE
4949/tcp  closed unknown
```

となり、取得できない。

### Munin サーバー

リソース情報を集約したいサーバーの設定は munin-node で設定したものをホストごとに用意するだけ。

監視ノードごとに設定ファイルを分割すると、サーバー設定の管理がしやすいので、`/etc/munin/conf.d/` 以下に、host_name 名のファイルを作る。

#### vim /etc/munin/conf.d/net.yulii.conf

```sh
[yulii.net]
    address 192.168.0.100
    port 4949
    use_node_name yes
```

いったん最小限の設定だが、こんな感じであっさり複数台のリソース監視をまとめられます。
