---
layout: post
title:  "Apache のパフォーマンスチューニング設定"
date:   2010-09-01 01:38:18 UTC+9
category: engineering
tags: server apache performance
---

## MMapFile でキャッシュの設定

MMapFile でレギュラーファイルをキャッシュする。ディレクトリは指定できない。

### モジュールの読み込み設定

```
LoadModule file_cache_module modules/mod_file_cache.so
```

キャッシュに設定したファイルを変更した場合は必ず Apache を再起動すること。

### 設定ファイルの作成 (ディレクトリを登録したい場合)

出力結果をチェックしてキャッシュするファイルのリストが正しいか確認する。

```sh
find /var/www/html/img/ -type f -print | sed -e 's/.*/MMapFile &/'
```

上記の結果をもとに設定ファイルの作成する。

```sh
find /var/www/html/img/ -type f -print | sed -e 's/.*/MMapFile &/' > ~/work/conf/mmap.conf
```

`/etc/apache2/conf.d/` 以下に配置して Apache に読み込ませる。

## KeepAlive の設定

KeepAlive を有効にすることで無駄なリソースを削減する。リソースを再利用することで，コネクションのオープンとクローズの回数を減らすことができる。

### /etc/apache2/apache2.conf

リクエストの数とタイムアウトの設定を記述する。

```sh
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
```

## プロセスとスレッド生成のチューニング

最大値がサーバのスペックを超えないようにする。

### プロセス数の設定

StartServers が多いとサービスダウン時間が大きくなるので注意。 MaxClients がサーバスペックを超えないように・・・。

```sh
<IfModule mpm_prefork_module>
    StartServers          5
    MinSpareServers       5
    MaxSpareServers      10
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule>
```

### スレッド数の設定

```sh
<IfModule mpm_worker_module>
    StartServers          2
    MaxClients          150
    MinSpareThreads      25
    MaxSpareThreads      75
    ThreadsPerChild      25
    MaxRequestsPerChild   0
</IfModule>
```
