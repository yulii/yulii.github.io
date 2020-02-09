---
layout: post
title:  "Nginx で Tomcat へリクエストを繋げる設定"
date:   2011-05-23T14:42:21+0900
category: engineering
tags: server nginx tomcat
---

## Tomcat と Nginxの連携

Tomcat へリクエストを繋げるには `proxy_pass` でURL を指定するだけでOK. ただし、ユーザがアクセスして来た IP アドレス等を Java から取得するために、Tomcat へデータを引き継ぐ設定が必要になる。

### Nginx の設定例

Proxy Header で Tomcat へリクエスト内容を引き継ぐ設定をする。また、静的ファイルと Java アプリケーションを `location` で切り分ける。

```
server {
    listen       80;
    server_name  sample.yulii.net;
    access_log   logs/sample.access.log main;

    # Proxy Header
    proxy_redirect    off;
    proxy_set_header  Host                $http_host;    # Host 情報を引き継ぐ
    proxy_set_header  X-Real-IP           $remote_addr;
    proxy_set_header  X-Forwarded-Host    $http_host;
    proxy_set_header  X-Forwarded-Server  $host;
    proxy_set_header  X-Forwarded-For     $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto   http;
    proxy_max_temp_file_size          0;

    location / {
        rewrite   ^/$  /context  permanent;
    }

    location ~ ^/context/(img|js|css|pict)/ {
        root /var/projects/tomcat/webapps;
        expires 30d;
    }

    location /context {
        proxy_pass      http://127.0.0.1:8080;
    }
}
```
