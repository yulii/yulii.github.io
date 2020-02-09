---
layout: post
title:  "Nginx のDNS 名前解決とS3 やELB へのリバースプロキシ"
date:   2015-08-15T17:51:23+0900
category: engineering
tags: server nginx aws
---

Nginx をフロントに立てて、バックエンドをごにょごにょするといろいろ捗ると思います。
ただ、バックエンドがAWS のようにAuto Scaling が働く場合、IP アドレスが変わってトラブルになることがあります。

## リバースプロキシの設定

`proxy_pass` にURI 指定すると、リクエストを転送処理できます。
必要に応じて `proxy_set_header`, `proxy_hide_header` を指定する事で、転送先サーバーにリクエストヘッダーを送信できます。

```
server {
  listen      80;
  server_name example.com;

  location / {
    proxy_pass http://proxy.example.com;
  }
}
```


### Nginx 内部の名前解決

デフォルトの挙動として、Nginx は起動時に名前解決を行いIP アドレスをキャッシュします。
AWS のELB やS3 などのエンドポイントのように、一定期間でIP アドレスが動的に変更される場合は問題が発生します。
サーバーをIP アドレスで指定している場合、サーバーネームのIP が変更されない場合は特に問題ありません。

`resolver` にDNS を指定することで定期的に名前解決を行ってくれます。
また、デフォルトではDNS のTTL の時間だけキャッシュしてくれるようです。
`valid` を指定することでキャッシュ時間をNginx 側で制御できます。

```
server {
  listen      80;
  server_name example.com;

  location / {
    resolver 8.8.8.8;
    proxy_pass http://proxy.example.com;
  }
}
```

_cf. [resolver ディレクティブ](http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver)_

## S3 やELB へのリバースプロキシ

VPC 内のインスタンスであれば、AWS が自動的に割当てたDNS サーバーを利用することできます。
IP アドレスは、VPC ネットワーク範囲のベースに「プラス 2」した IP アドレスです。
VPC の CIDR 範囲が `10.0.0.0/16` である場合、DNS サーバーの IP アドレスは `10.0.0.2` です。

```
server {
  listen      80;
  server_name example.com;

  location / {
    resolver 10.0.0.2 valid=5s;
    proxy_pass http://proxy.example.com;
  }
}
```

逆にDNS への問い合わせが不要なら `resolver` は指定せずにNginx のキャッシュ任せ or IP アドレス指定にすると良いと思います。
