---
layout: post
title:  "Apache Tomcat のインストールと設定"
date:   2011-02-16T03:26:09+0900
category: engineering
tags: server tomcat
---

## Apache Tomcat インストール&設定

Tomcat のインストールと公開サーバーで動かすための準備について

### Java (JDK) インストール

Java SE DownloadsのサイトからJDKのRPMをダウンロードしてインストールする。

```sh
cd /usr/local/src
wget http://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_Developer-Site/en_US/-/USD/VerifyItem-Start/jdk-6u24-linux-i586-rpm.bin?BundledLineItemUUID=5aOJ_hCunKwAAAEuhUVZCyxN&OrderID=C5iJ_hCuq2IAAAEubkVZCyxN&ProductID=xpeJ_hCwsEQAAAEtAMoADqmS&FileName=/jdk-6u24-linux-i586-rpm.bin
chmod +x jdk-6u24-linux-i586-rpm.bin
./jdk-6u24-linux-i586-rpm.bin
```

#### 環境変数の設定

`/etc/profile` に必要な変数を定義する。

```sh
export JAVA_HOME=/usr/java/default
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
```

default は jdk1.6.0_24 と明示的に指定しても OK.

### 起動ユーザ作成

Tomcat プロセスの起動用ユーザを作成する。

```sh
useradd -d /opt/tomcat -s /sbin/nologin tomcat
```

### インストール

Tomcat ユーザのホームディレクトリにファイルをダウンロードして展開する。

```sh
cd /opt/tomcat
wget http://ftp.jaist.ac.jp/pub/apache/tomcat/tomcat-6/v6.0.32/bin/apache-tomcat-6.0.32.tar.gz
tar -xvzf apache-tomcat-6.0.32.tar.gz
mv apache-tomcat-6.0.32.tar.gz tomcat_webapp
```

### Apache Commons Daemon

Tomcat の `/bin` ディレクトリにあるファイルを取り出す。

#### commons-daemon-native.tar.gz (旧 jsvc.tar.gz)

圧縮ファイルを展開して `make` する。

```sh
cd /opt/tomcat/tomcat_webapp/bin
mv commons-daemon-native.tar.gz /usr/local/src
tar -xzvf commons-daemon-native.tar.gz
cd commons-daemon-1.0.5-native-src/unix/
./configure --with-java=/usr/java/default
make
cp jsvc /opt/tomcat/tomcat_webapp/bin
```
