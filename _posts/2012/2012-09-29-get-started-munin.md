---
layout: post
title:  "Munin ではじめるサーバ監視"
date:   2012-09-29T08:13:48+0900
category: engineering
tags: server munin supervision
---

## リソース監視ツール Munin

ちゃんとサーバ監視しようと思い腰を上げて Munin 入れてみた。

### インストール手順 @CentOS 5

```sh
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm
yum install munin
```

### Warning ログの対応

Munin のログに以下のような警告メッセージが表示される

```sh
tail -f /var/log/munin/munin-html.log
2012/09/29 14:30:08 [PERL WARNING] Use of uninitialized value in string eq at /usr/share/perl5/vendor_perl/Munin/Master/HTMLConfig.pm line 465.
2012/09/29 14:30:08 [PERL WARNING] Use of uninitialized value in string eq at /usr/share/perl5/vendor_perl/Munin/Master/HTMLConfig.pm line 492.
```

5分毎にWarning 吐かれても困るので、スクリプトを修正して対応する

#### /usr/share/perl5/vendor_perl/Munin/Master/HTMLConfig.pm の修正

##### 465行目の if 文の条件式を修正

```perl
if (defined $config->{'graph_strategy'} && $config->{'graph_strategy'} eq "cgi") {
```

##### 492行目の if 文の条件式を修正

```perl
next if (defined $config->{'graph_strategy'} && $config->{'graph_strategy'} eq "cgi");
```

### Munin の設定

設定ファイルがごちゃごちゃしないように `/etc/munin/conf.d/` 以下に作成

#### /etc/munin/conf.d/watch-node.conf

```sh
host_name yulii.net

[yulii.net]
    address 127.0.0.1
    port 54949
    use_node_name yes
```

#### /etc/munin/conf.d/watch-node.conf

リソース監視対象 (`munin-node`) のMunin ポート番号を変更

```sh
port 54949
```

Cron で5分毎にサマリが HTML で出力されるので、適宜Web サーバでファイルが見れるように設定したら終わり。デフォルト設定では `/var/www/html/munin` 以下に出力される。
