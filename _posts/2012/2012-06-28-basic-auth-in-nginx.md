---
layout: post
title:  "Nginx でBasic 認証の設定"
date:   2012-06-28T08:20:54+0900
category: engineering
tags: server nginx
---

## Basic 認証の設定方法

Basic 認証で利用するユーザ名とパスワードの設定ファイルを `auth_basic_user_file` で指定する

```
server {
  listen       80;
  server_name  yulii.net;
  access_log   logs/net.yulii.access.log main;

  auth_basic "Restricted Access";
  auth_basic_user_file /etc/nginx/conf/auth_basic/.htpasswd;

  location / {
    root html;
    index index.html index.htm;
  }
}
```

Basic 認証のアカウント発行は `htpasswd` コマンドが便利。

`htpasswd` コマンドは Apache のパッケージ `apache2-utils` に含まれている。

```sh
$ htpasswd -n yulii
New password:
Re-type new password:
yulii:pxX7w0IvuRflQ
```

### htpasswd コマンドの注意点

運用上注意しないと設定ファイルを削除してしまうので注意!!

#### htpasswd コマンドのオプション

- b : パスワードをコマンドライン引数として指定 (コマンド履歴、ショルダーハッキングに注意)
- c : 設定ファイルの新規作成 (既にファイルがある場合は警告なしに強制上書き)
- n : 実行結果を標準出力する
- s : パスワードを SHA でハッシュ化

基本は n オプションで標準出力させた方が無難。面倒だけど手動でファイルに追加する。
