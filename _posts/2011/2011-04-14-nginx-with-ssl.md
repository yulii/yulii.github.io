---
layout: post
title:  "Nginx に SSL 証明書を入れて HTTPS の設定"
date:   2011-04-14 16:34:24 UTC+9
category: server
tags: nginx
---

## Nginx で SSL 証明書の設定

### 鍵の作成

暗号化アルゴリズムと鍵のビット長を指定する。1024 ビットより強度を高く設定する事をお勧めします。

```sh
openssl genrsa -des3 -out <yulii.net>.key 2048
```

### 署名要求

作成した鍵を利用してサーバーの情報を設定する。

```sh
openssl req -new -key <yulii.net>.key -out <yulii.net>.csr
```

コマンド実行後にサーバー情報の入力を求められるので、適宜設定する。

```
Country Name (2 letter code) [GB]:JP
State or Province Name (full name) [Berkshire]:Tokyo
Locality Name (eg, city) [Newbury]:Shinjuku-ku
Organization Name (eg, company) [My Company Ltd]:<yulii.net>
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:<yulii.net>
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

### 証明書
中間証明書を直接指定するディレクティブが用意されていないので，サーバ証明書と中間証明書を結合したものを `ssl_certificate` で指定する。

```sh
cat server.cer cacert.cer > cert.pem
```

#### 証明書の結合イメージ

```
-----BEGIN CERTIFICATE-----
[サーバ証明書]
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
[中間証明書]
-----END CERTIFICATE-----
```

