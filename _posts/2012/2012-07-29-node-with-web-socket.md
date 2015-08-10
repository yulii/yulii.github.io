---
layout: post
title:  "Node.js + WebSocket で双方向通信をはじめる"
date:   2012-07-29 18:43:21 UTC+9
category: javascript
tags: nodejs websocket
---

## Node.js のインストール

Mac でやったけど、おそらくLinux 系でも同様にいけるはず。

```sh
cd /usr/local/src/
git clone git://github.com/ry/node.git
cd node
./configure
make
sudo make install
```

### Node パッケージ管理 npm のインストール

```sh
curl http://npmjs.org/install.sh | sh
```

### Node で Hello World!

```javascript
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World!\n');
}).listen(8124, "127.0.0.1");
console.log('Server running at http://127.0.0.1:8124/');
```

hello.js など適当に保存して実行

```sh
node hello.js
```

ブラウザなどで http://127.0.0.1:8124/ へアクセスして “Hello World!” が表示されたらOK.

## WebSocket のインストール

WebSocket 用の Node ライブラリ Socket.IO をインストールする

```sh
npm install socket.io
```

本家のサンプルをとりあえず動かしてみる

### Server 側のアプリケーションを作成

app.js として、以下のコードをコピペ保存する

```javascript
var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')

app.listen(8124);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

io.sockets.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});
```

### Client 側のView を作成

index.html として、以下のコードをコピペ保存する

```html
<!DOCTYPE html>
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8"/>
    <title>Hello WebSocket</title>
</head>
<body>
<script src="/socket.io/socket.io.js"></script>
<script>
  var socket = io.connect('http://localhost');
  socket.on('news', function (data) {
    console.log(data);
    socket.emit('my other event', { my: 'data' });
  });
</script>
</body>
</html>
```

### Node.js で WebSocket を動かしてみる

まずは、Node アプリケーションを実行&起動

```sh
node app.js
```

ブラウザで http://127.0.0.1:8124/ へアクセスする。画面が真っ白ならOK. Node を起動したコンソール上にログっぽいメッセージが流れるはず。

Node のデフォルト出力 “Hello Node.js” とテキスト (HTML でなく単なる plain/text) が表示されたら NG.

## WebSocket についての補足

従来の Commet などの双方向通信とは異なり、TCP のハンドシェイク手続きを何度も行う必要がなく、サーバとクライアントが一度 TCP コネクションを確立したあとは、そのコネクション上で専用プロトコルを使い必要な通信をすべて行うことが出来る。

具体的には、HTTP 通信でセッションを確立し、その後 WebSocket 通信へ移行する。Firefox の Live HTTP Headers で通信を覗いてみると概要が分かる。

初回はただの HTTP リクエストを送る。

```
GET / HTTP/1.1
Host: 127.0.0.1:8124
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:14.0) Gecko/20100101 Firefox/14.0.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: ja,en-us;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Connection: keep-alive
```

HTTP 通信から WebSocket 通信への切り替えリクエストを送る。

```
GET /socket.io/1/websocket/X-8776MBmRib_qXjzMFO HTTP/1.1
Host: 127.0.0.1:8124
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:14.0) Gecko/20100101 Firefox/14.0.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: ja,en-us;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Connection: keep-alive, Upgrade
Sec-WebSocket-Version: 13
Origin: http://127.0.0.1:8124
Sec-WebSocket-Key: bmxxAd1YiaYzLLnDb9pAEg==
Pragma: no-cache
Cache-Control: no-cache
Upgrade: websocket
```

`Upgrade: websocket` なるヘッダー情報が入っている。その他、WebSocket のハンドシェイクを開始するために、 `Sec-WebSocket-Key` などが必要となる。

接続確立すると `101 Switching Protocols` のレスポンスが返ってくる。

```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: sk85MqSFg1CGhAYRlSvctpzSALA=
```

レスポンスヘッダーの中には、`Sec-WebSocket-Accept` なるセッション確立したことを示すデータが含まれる。

細かい仕様は、[RFC6455 The WebSocket Protocol](http://tools.ietf.org/html/rfc6455) で。

