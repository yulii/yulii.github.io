---
layout: post
title:  "ライブ配信サーバー構築 〜 エンコーダ (FFmpeg) の設定 〜"
date:   2009-11-10 08:16:32
category: server
tags: ffmpeg ubuntu
---

## エンコーダの準備 (Ubuntu 8.10 Server)

FFmpeg を利用してカメラの映像をエンコードします。IEEE1394 (`/dev/raw1394`) から入力をもらうことを想定。

公開用の Web サーバとエンコーダを分けて用意する場合は両方に同じ FFmpeg をインストールすること。

## FFmpeg

余計なライブラリや設定が入っているかもしれません。

### インストール

- FFmpeg (FFserver デフォルトで付属) + 必要なコーデック
- dvgrab
    - IEEE1394 の入力を受け取るソフト


### ビルド環境

ソースからビルドする環境を準備する

```sh
sudo apt-get install gcc build-essential autoconf automake texinfo libtool gawk git git-core subversion nasm yasm
```

### ソースからインストールする際の注意点

- ソースの保存場所 `/usr/local/src` で作業する
- `./configure --help` でオプションを必ず確認する。
    - `--enable-hoge` と `--with-hoge` 類に注意する。
- `sudo` を念のため全部につけてある。

### コーデックの準備

依存関係があるものもあるので順番に注意

#### lame

```sh
sudo wget http://sourceforge.net/projects/lame/files/lame/3.98/lame-398.tar.gz/download
sudo tar xzvf lame-398.tar.gz
cd lame-398
sudo ./configure
sudo make
sudo make install
```

#### x264

```sh
sudo git clone git://git.videolan.org/x264.git
cd x264
sudo ./configure --enable-shared              # オプションに注意 (要らないかも)
sudo make
sudo make install
```

#### libmp4v2

```sh
sudo wget http://resare.com/libmp4v2/dist/libmp4v2-1.5.0.1.tar.bz2
sudo tar -xjvf libmp4v2-1.5.0.1.tar.bz2
cd libmp4v2-1.5.0.1
sudo ./configure
sudo make
sudo make install
```

#### libogg

```sh
sudo wget http://downloads.xiph.org/releases/ogg/libogg-1.1.4.tar.gz
sudo tar xzvf libogg-1.1.4.tar.gz
cd libogg-1.1.4
sudo ./configure
sudo make
sudo make install
```

#### liboil

```sh
sudo wget http://liboil.freedesktop.org/download/liboil-0.3.16.tar.gz
sudo tar xzvf liboil-0.3.16
cd liboil-0.3.16
sudo ./configure
sudo make
sudo make install
```

#### libraw1394

```sh
sudo wget http://sourceforge.net/projects/libraw1394/files/libraw1394/libraw1394-2.0.0.tar.gz/download
sudo tar xzvf libraw1394-2.0.0.tar.gz
cd libraw1394-2.0.0
sudo ./configure
sudo make
sudo make install
sudo make dev          # make dev すると /dev/raw1394 のデバイスファイルが作成される
```

#### libfaad2

```sh
sudo wget http://downloads.sourceforge.net/faac/faad2-2.7.tar.gz
sudo tar xzvf faad2-2.7.tar.gz
cd faad2-2.7
sudo ./configure
sudo make
sudo make install
```

#### faac

```sh
sudo wget http://downloads.sourceforge.net/faac/faac-1.28.tar.gz
sudo tar xzvf faac-1.28.tar.gz
cd faac-1.28
sudo ./configure --with-mp4v2           # オプションに注意 (要らないかも)
sudo make
sudo make install
```

#### libdc1394

```sh
sudo wget http://sourceforge.net/projects/libdc1394/files/libdc1394-2/2.1.2/libdc1394-2.1.2.tar.gz/download
tar xzvf libdc1394-2.1.2.tar.gz
cd libdc1394-2.1.2
sudo ./configure
sudo make
sudo make install
```

#### libgsm

```sh
sudo wget http://user.cs.tu-berlin.de/~jutta/gsm/gsm-1.0.13.tar.gz
tar xzvf gsm-1.0.13.tar.gz
cd gsm-1.0.13
```

- Makefile の修正

```sh
sudo vi Makefile
INSTALL_ROOT =/usr
GSM_INSTALL_INC = $(GSM_INSTALL_ROOT)/include
```

- 74行目前後の `INSTALL_ROOT =` を `INSTALL_ROOT =/usr` に変更
- `GSM_INSTALL_INC = $(GSM_INSTALL_ROOT)/inc` を`GSM_INSTALL_INC =$(GSM_INSTALL_ROOT)/include` に変更

```sh
sudo make
sudo make install
```

古いバージョンのコーデックがインストールされている時に削除しようとしてエラーが出ます。コーデックも関連ライブラリもちゃんとインストールされますので無視してください。

#### libvorbis

```sh
sudo wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.2.3.tar.gz
sudo tar xzvf libvorbis-1.2.3.tar.gz
cd libvorbis-1.2.3
sudo ./configure
sudo make
sudo make install
```

./configure の test run でエラーしたら $ sudo ldconfig して ./configure を再実行

#### libtheora

```sh
sudo wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
sudo tar xjvf libtheora-1.1.1.tar.bz2
cd libtheora-1.1.1
sudo ./configure
sudo make
sudo make install
```

#### libao

```sh
sudo wget http://downloads.xiph.org/releases/ao/libao-0.8.8.tar.gz
sudo tar xzvf libao-0.8.8.tar.gz
cd libao-0.8.8
sudo ./configure
sudo make
sudo make install
```

#### xvidcore

```sh
sudo git clone git://git.debian-maintainers.org/git/unofficial/xvidcore.git
cd xvidcore/build/generic
sudo ./configure
sudo make
sudo make install
```

#### libdirac (FFmpeg のビルドでエラーしたので結果的には要らなかった)

```sh
sudo wget http://sourceforge.net/projects/dirac/files/dirac-codec/Dirac-1.0.2/dirac-1.0.2.tar.gz/download
sudo tar xzvf dirac-1.0.2.tar.gz
cd dirac-1.0.2
sudo ./configure
sudo make
sudo make install
```

### FFmpeg のビルド

```sh
sudo svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg
cd ffmpeg
sudo ./configure --enable-gpl --enable-nonfree --enable-pthreads --disable-debug  --enable-libdc1394 --enable-libfaac --enable-libfaad --enable-libgsm --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-zlib --enable-bzlib  --enable-version3 --enable-avfilter --enable-avfilter-lavf
sudo make
sudo make install
```

ビルドオプションが長いけどこれでうまくいったので。(たぶん要らないのいっぱい)

### FFmpeg の動作チェック

- FFmpeg を実行して `/dev/raw1394` の入力が受け取れるかチェック。

```sh
sudo ffmpeg -f libdc1394 -s 320x240 -i /dev/raw1394 test.swf
```

パラメータが動いてエンコードが始まったらOK.

```sh
 libdc1394 error: Failed to initialize libdc1394
```

このようなエラーが返ってきたらNG. IEEE1394 の DV Input にまだまだバグがあるっぽい。 (Ubuntu 固有の問題かも)

- NG だったら dvgrab をインストールする

```sh
sudo apt-get install dvgrab
```

これを利用してデバイスから映像を受け取ります。

```
IEEE1394 (Web Cam) -> dvgrab (DV avi) -> FFmpeg -> swf
```

という流れ。

- dvgrab を利用して FFmpeg を実行する

```sh
sudo dvgrab --format dv2 - | ffmpeg -f dvvideo -s 320x240 -f pcm_s16le -i - -ar 44100 -acodec libmp3lame test.swf
```

ハイフン "-" で標準入力出力を扱える。たまに固まるが パイプの前の sudo の認証が切れているのが原因。sudo vi など適当に sudo をいったん認証通してから再度実行。

