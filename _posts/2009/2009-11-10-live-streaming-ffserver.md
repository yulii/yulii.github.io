---
layout: post
title:  "ライブ配信サーバー構築 〜 配信サーバー (FFserver) の設定 〜"
date:   2009-11-10 08:04:03 UTC+9
category: server
tags: ffmpeg centos
---

## 配信サーバの設定 (CentOS 5.4)

### FFserver

FFmpeg に付属されている FFserver を使用する。配信サーバとWeb サーバは同じマシンを使用する。エンコーダマシンを分ける場合はまた別途 Web サーバに FFmpeg をインストールする。

#### /etc/ffserver.conf

~~~
Port 8090
BindAddress 0.0.0.0
MaxClients 1000
MaxBandwidth 8000
CustomLog -
NoDaemon
~~~

### フィード設定 (配信するファイル)

~~~
<Feed feed.ffm>
 File /tmp/feed.ffm>
 FileMaxSize 12M
 ACL allow 127.0.0.1
 ACL allow <Encoder IP>
 </Feed>

 <Stream streaming.flv>
 Feed feed.ffm
 Format flv
 VideoFrameRate 24
 VideoSize 640x480
 VideoBitRate 1200
 PreRoll 0
 VideoIntraOnly
 AudioBitRate 96
 AudioSampleRate 44100
 </Stream>

 # ステータスログ画面の表示設定
 <Stream status.html>
 Format status
 ACL allow localhost
 </Stream>

 # リダイレクト設定
 <Redirect index.html>
 URL http://wiki.yulii.net/ffmpeg
 </Redirect>
~~~

### 配信サーバの起動

~~~sh
ffserver -f /etc/ffserver.conf
~~~

### ログの保存

~~~sh
ffserver -f /etc/ffserver.conf >> /var/log/ff/streaming.log
~~~

FFserver の出力するデータがログになるので，リダイレクトで書き込む。間違って上書きしないように ">>" で書き込む。

