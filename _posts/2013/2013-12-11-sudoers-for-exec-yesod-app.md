---
layout: post
title:  "sudoers でプロセス起動専用ユーザと一般ユーザの権限管理"
date:   2013-12-11 14:31:40 UTC+9
category: engineering
tags: unix yesod
---

## sudoers 設定

基本は `visudo` コマンドで編集する。`vi` と同じ方法で編集可能です。ファイルを閉じたタイミングで構文チェックをしてくれます。

### 権限毎に設定ファイルを分ける

設定が増えたときのために、ファイルを分けて編集する形にした。読み込む順番が分からなかったので、プレフィックスに連番を付けておいた。

```sh
# ls -l /etc/sudoers.d/
total 8
-r--r----- 1 root root 458 Dec 10 14:33 000_alias
-r--r----- 1 root root 101 Dec 10 15:02 001_devops
```

#### /etc/sudoers.d/000_alias

設定に利用するエイリアスの定義をまとめておく。対象ユーザ、実行ユーザ、ホスト、コマンドなどを定義する。

```sh
# User alias specification
User_Alias   DEVOPS = yulii

# Runas alias specification
Runas_Alias  SU     = root
Runas_Alias  ANGEL  = angel

# Host alias specification
Host_Alias   LO     = 127.0.0.1

# Cmnd alias specification
Cmnd_Alias   SH     = /bin/sh, /bin/bash
Cmnd_Alias   KILL   = /bin/kill
Cmnd_Alias   APP_YULII = /var/opt/angel/build_yulii_production
```

#### /etc/sudoers.d/001_devops

アカウント単位で、`sudo` 可能なホスト、実行ユーザ、コマンドを制限する。ALL 指定できるが、不要な権限は付与せず、必要なものだけを許可しておく。

```sh
DEVOPS    LO = (ANGEL) NOPASSWD: SH, APP_YULII, (SU) PASSWD: KILL
```

エイリアス `DEVOPS` で定義されたユーザに、ホスト `LO` 上で`sudo` 権限を付与した。`ANGEL` 権限で `SH` と `APP_YULII` をパスワード認証なしの実行許可、`SU` 権限で `KILL` をパスワード認証付きの実行許可。

## 実行スクリプト

Yesod アプリケーションをビルドするスクリプトを用意する。`sudo` からの実行権限は上記で設定済み。（本当は、Jenkins 立てて自動化する方が柔軟性があって良いと思う。）

### /var/opt/angel/build_yulii_production

`$APP_ROOT` は適宜設定する。

```sh
#!/bin/bash
pull() {
  cd $APP_ROOT && git pull
}
clean() {
  cabal clean
}
install() {
  cabal install --only-dependencies
}
reinstall() {
  cabal update && cabal install --only-dependencies --force-reinstalls
}
build() {
  cabal configure && cabal build
}

source $HOME/.bash_profile  # 実行に必要なパスはあらかじめ用意しておく
case "$1" in
  upgrade)  pull && clean && reinstall && build ;;
  *)        pull && clean && install && build ;;
esac
```

### 実行コマンド

#### 通常のビルド

```sh
sudo -u angel /var/opt/angel/build_yulii_production
```

#### 依存モジュール変更時のビルド

`cabal update` と `cabal install --force-reinstalls` も一緒に実行する。

```sh
sudo -u angel /var/opt/angel/build_yulii_production upgrade
```
