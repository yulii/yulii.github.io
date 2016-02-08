---
layout: post
title:  "ライブ配信サーバー構築 (FFmpeg/FFserver)"
date:   2009-11-10 08:01:04 UTC+9
category: server
tags: ffmpeg ubuntu
---

## Flash Player 向けのライブ配信サーバー構築

FFmpeg (FFserver) を使って Flash Player 向けにライブ配信映像するプロジェクトのまとめ。

### お品書き

- [エンコーダ (FFmpeg) の設定]({% post_url 2009-11-10-live-streaming-ffmpeg %})
- [配信サーバー (FFserver) の設定]({% post_url 2009-11-10-live-streaming-ffserver %})
- [JW Player の埋め込み]({% post_url 2009-11-10-live-streaming-jw-player %})

## システム構成

- 入力: IEEE1394
- 出力: FLV (flv/mp3)

IEEE1394 関連のデバイスが Fedora だとゴタゴタしているようなので Ubuntu を使用する。

~~~
[カメラ] --> [A/D]
  --> [IEEE1394 (/dev/raw1394)] --> [Encode (FFmpeg)]       # エンコーダマシン
  --> [Stream (FFserver)] --> [Flash Player (JW Player)]    # 配信サーバ兼 Web サーバ
~~~

### ソフトウェア構成

- Ubuntu 8.10 server
- FFmpeg

~~~
--enable-gpl
--enable-nonfree
--enable-pthreads
--disable-debug
--enable-libdc1394
--enable-libfaac
--enable-libfaad
--enable-libgsm
--enable-libmp3lame
--enable-libtheora
--enable-libvorbis
--enable-libx264
--enable-libxvid
--enable-zlib
--enable-bzlib
--enable-version3
--enable-avfilter
--enable-avfilter-lavf
~~~

- dvgrab
    - FFmpeg の IEEE1394 の入力ライブラリが動かなかったので代わりに使用 (Ubuntu のバグかも)
