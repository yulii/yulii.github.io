---
layout: post
title:  "Apache でサーバーの状態を表示する"
date:   2010-08-21 14:10:02
category: server
tags: apache
---

## サイトの動作のスナップショットの取得

server-status ハンドラーを呼び出すことで Apache の動作状況を取得する事ができます。

### server-status ハンドラーの設定

server-status が含まれている mod_status モジュールを有効にする。

```
LoadModule status_module modules/mod_status.so
```

URL から閲覧可能にするために Location を設定する。

```
ExtendedStatus On
<Location /server-status>
    SetHandler server-status
    Order deny,allow
    Deny from all
    Allow from 192.168.1           # プライベートネットワーク内のみのアクセスを許可
</Location>
```

`/server-status` にアクセスするとみられる。ExtenedStatus ディレクティブを On にすると詳細を表示できる。

