---
layout: post
title:  "Amazon S3 をコマンドラインから操作する s3cmd"
date:   2014-09-04 19:51:15 UTC+9
category: engineering
tags: server aws
---

Amazon S3 に対する作業は Management Console や AWS SDK (PHP, Java, Ruby, .NET) で行うことができる。ただ、バックアップ処理やFTP っぽくファイルサーバー扱いするときはコマンドラインで使える `s3cmd` が便利。

## インストール

`GPG` が必要なので一緒にインストールする。


```
brew install s3cmd gpg
```

### S3 への接続設定

アクセスキーとシークレットキーをAWS コンソールからあらかじめ発行しておき、`s3cmd --configure` を実行する


```
$ s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3
Access Key: XXXXXX
Secret Key: XXXXXX

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password: XXXXXX
Path to GPG program [None]:  /usr/local/bin/gpg

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP and can't be used if you're behind a proxy
Use HTTPS protocol [Yes]: Yes

New settings:
  Access Key: XXXXXX
  Secret Key: XXXXXX
  Encryption password: XXXXXX
  Path to GPG program: None
  Use HTTPS protocol: True
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] y
Please wait...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Success. Encryption and decryption worked fine :-)

Save settings? [y/N] y
Configuration saved to '/Users/yulii/.s3cfg'
```

#### 参考：GPG をインストールしていない時のエラー

```
Now verifying that encryption works...
ERROR: Test failed: GPG program not found

```


## S3 の操作方法

`s3cmd -h` で使えるコマンド一覧が見れる。

## Middleman + S3 で静的Webページの管理

Middleman でビルド処理を行い、`build/` ディレクトリを丸ごとアップロードする。

```
bundle exec middleman build
s3cmd put -r build/ s3://<bucket-name>/path/to/file
```

適宜シェルスクリプトにまとめて置くなどすると運用が楽。
