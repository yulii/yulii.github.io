---
layout: post
title:  "SSH のセキュリティ設定メモ"
date:   2010-07-13 18:59:27 UTC+9
category: engineering
tags: server security
---

## SSH のセキュリティ設定について

不要なものはすべて制限し、例外的なものを Match 構文で上書き許可する

### /etc/ssh/sshd_config

基本的な認証セキュリティの設定

#### root ユーザによる直接ログインを不許可

```
PermitRootLogin no
```

#### パスワード認証を不許可

```
PasswordAuthentication no
```

## Match 構文

Match 構文による設定は OpenSSH 4.4 以降のバージョンで使用可能です。外部からは公開鍵認証だが、内部からはパスワード認証可にしたいなど条件によって設定を変えたい場合は Match 構文を利用する。

Match 構文は必ず設定ファイルの最後にまとめて記述する。

### Match 構文による条件式

- Match User %{ユーザ名}
- Match Group %{グループ名}
- Match Host %{FQDN}
- Match Address xxx.xxx.xxx.xxx

FQDN は対象サーバ内での名前解決結果に依存、 `/etc/hosts` ファイルで静的定義したものも有効です。IP アドレスは、任意のオクテットでワイルドカード '*' を使用可能です。

### 再定義可能な設定オプション

下記以外の設定項目は Match 構文による再定義は出来ない

- AllowTcpForwarding
- Banner
- ForceCommand
- GatewayPorts
- GSSApiAuthentication
- KbdInteractiveAuthentication
- KerberosAuthentication
- PasswordAuthentication
- PermitOpen
- RhostsRSAAuthentication
- RSAAuthentication
- X11DisplayOffset
- X11Forwarding
- X11UseLocalHost
