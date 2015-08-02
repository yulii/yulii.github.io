---
layout: post
title:  "分散Key/ValueストアKai のインストール"
date:   2009-03-06 07:59:46
category: database
---

## 分散Key/ValueストアKai の始め方

分散Key/Valueストア Kai のインストール手順と動作確認です。

### Erlang のインストール

ソースからインストールを行う。Erlang v5.6 (OTP R12B) 以降をインストールしておいてください。

```sh
cd /usr/local/src
wget http://www.erlang.org/download/otp_src_R12B-5.tar.gz
tar zxvf otp_src_R12B-5.tar.gz
cd otp_src_R12B-5
./configure
make
make install
```

#### No curses library functions found

上記のエラーが出る場合は、足りないライブラリをインストールしておく。

```sh
sudo apt-get install ncurses-devel
```


#### APPLICATIONS DISABLED

```
crypto         : No usable OpenSSL found
jinterface     : No Java compiler found
odbc           : ODBC library - link check failed
ssh            : No usable OpenSSL found
ssl            : No usable OpenSSL found
```

上記のメッセージを参考に、必要なライブラリを追加インストールする。

```sh
sudo apt-get install sun-java6-jdk
sudo apt-get install libssl-dev
sudo apt-get install unixodbc-dev
```


#### 依存ライブラリのエラー対処

下記の様な [opt] エラーが出る場合

```
collect2: ld はステータス 1 で終了しました
make[4]: *** [../priv/bin/i686-pc-linux-gnu/ssl_esock] エラー 1
make[4]: ディレクトリ `/usr/local/src/otp_src_R12B-5/lib/ssl/c_src' から出ます
make[3]: *** [opt] エラー 2
make[3]: ディレクトリ `/usr/local/src/otp_src_R12B-5/lib/ssl/c_src' から出ます
make[2]: *** [opt] エラー 2
make[2]: ディレクトリ `/usr/local/src/otp_src_R12B-5/lib/ssl' から出ます
make[1]: *** [opt] エラー 2
make[1]: ディレクトリ `/usr/local/src/otp_src_R12B-5/lib' から出ます
make: *** [libs] エラー 2
```

Makefile の`LIBS` を修正する。

```sh
cd /usr/local/src/otp_src_R12B-5
vi lib/ssl/c_src/Makefile.in
   # LIBS を以下のように変更
   LIBS = @LIBS@ -lkeyutils -lselinux
```

一度 `make clean` してから再度 `./configure; make; make install`

#### m4: not found

必要なライブラリが足りていないので、m4 をインストール (`sudo apt-get install m4`) する。

```sh
m4   -DTARGET=i686-pc-linux-gnu -DOPSYS=linux -DARCH=x86 hipe/hipe_arm_asm.m4 > i686-pc-linux-gnu/opt/plain/hipe_arm_asm.h
/bin/sh: m4: not found
make[2]: *** [i686-pc-linux-gnu/opt/plain/hipe_arm_asm.h] Error 127
make[2]: Leaving directory `/home/yulii/work/cloud/src/otp_src_R12B-5/erts/emulator'
make[1]: *** [generate] Error 2
make[1]: Leaving directory `/home/yulii/work/cloud/src/otp_src_R12B-5/erts/emulator'
make: *** [depend] Error 2
```

### Kai のインストール

ソースからインストールする。

```sh
wget http://downloads.sourceforge.net/kai/kai-0.3.0.tar.gz
tar zxvf kai-0.3.0.tar.gz
cd kai-0.3.0
make
```

#### スタンドアローンで起動する

Kai のROOT ディレクトリ内で、`erl` から起動する。

```sh
erl -pa ebin -config kai -kai n 1 -kai r 1 -kai w 1

1> application:load(kai).
2> application:start(kai).
```

ok と出力が返ってくれば動作確認完了です。

