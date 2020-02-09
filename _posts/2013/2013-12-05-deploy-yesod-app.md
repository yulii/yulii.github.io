---
layout: post
title:  "Yesod アプリケーションの本番環境デプロイ"
date:   2013-12-05T04:22:12+0900
category: engineering
tags: haskell yesod
---

## デプロイ手順書

ソースをビルド (`cabal build`) して、生成された実行ファイルを `Production` 指定で動かすだけ。Yesod アプリケーションの ROOT ディレクトリ内で手順に沿ってコマンドを実行すればデプロイできる。Heroku 向けのデプロイ方法は、`./deploy/Procfile` に色々書いてある。

### ビルド手順

`cabal build` するだけだが、依存モジュールを追加したり変更が色々あったりするので、以下のコマンドを順に実行する。個人的な運用方法としては、シェルスクリプトで `&&` 結合して実行している。

```sh
cabal clean
cabal install --only-dependencies
cabal configure
cabal build
```

これで、`./dist/build/${app_name}/${app_name}` という実行ファイルが生成される。

### Production 環境でアプリを実行

`Production` を引数に指定して実行するだけ。

```sh
./dist/build/${app_name}/${app_name} Production --port 8080
```

デフォルトのポート番号は4321 です。プロセスをデーモン化するには、Angel を利用できる。

## アプリケーションプロセスのデーモン化

Angel を利用して、プロセス管理を行う。インストールは Cabal から出来る。

```sh
cabal install angel
```

### Angel で管理するプロセスの設定ファイルを作成する

`%{APP_NAME}` は適宜設定すること。

#### config/angel.conf

```
workers {
  directory = "/var/www/%{APP_NAME}"
  exec      = "./dist/build/%{APP_NAME}/%{APP_NAME} Production --port 8080"
  pidfile   = "/var/run/yesod/%{APP_NAME}.pid"
  stdout    = "/var/log/yesod/%{APP_NAME}.stdout.log"
  stderr    = "/var/log/yesod/%{APP_NAME}.stderr.log"
}
```

#### Angel の実行

```sh
angel ./config/angel.conf
```

これで、設定ファイルの内容の exec のコマンドを実行してくれる。また、プロセスが落ちていたら再起動してくれる。

設定とか細かい事は本家のGitHub を参照してください。
[https://github.com/MichaelXavier/Angel](https://github.com/MichaelXavier/Angel)


## Web サーバーとの連携

`%{APP_ROOT}` は適宜設定すること。

### Nginx の設定

`proxy_pass` で起動した Yesod アプリケーションを指定するだけ。

```
upstream yesod_backend {
  server 127.0.0.1:8080;
}

server {
  listen 80;
  server_name yulii.net;

  root %{APP_ROOT}/static;

  proxy_connect_timeout 60;
  proxy_read_timeout    60;
  proxy_send_timeout    60;

  location / {
    proxy_set_header X-Real-IP  $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_pass http://yesod_backend;
  }

  location /static {
    expires 1y;
    root %{APP_ROOT};
  }
}
```

アプリケーションのROOT ディレクトリを Nginx の root に指定すると気持ち悪い（配下に設定ファイルとかある）ので、 `/static` を設定している。


## 番外編：アプリケーション実行ユーザの切り分け

実際の運用時には、アプリケーションの実行ユーザを Yesod 用に切り分けている。

### Yesod 専用ユーザの作成

`angel` というユーザを作成する

```sh
useradd -d /var/opt/angel -s /sbin/nologin angel
```

Haskell や Cabal が使えるように `/var/opt/angel/.bash_profile` へパスを追加して、Angel をインストールする。

```sh
su - -s /bin/bash angel -c "cabal update"
su - -s /bin/bash angel -c "cabal install angel"
```

以上で、Yesod を動かす準備ができるので、`su - -s /bin/bash angel` でビルド&デプロイを実行する。

### デプロイ用のシェルスクリプト

運用時に利用しているシェルスクリプトを作成しておく。各スクリプトで利用する `$APP_ROOT` は適宜設定する。

#### tasks/update-sources.sh

```sh
su - -s /bin/bash angel -c "cd $APP_ROOT && git pull"
```

#### tasks/build-production.sh

```sh
su - -s /bin/bash angel -c "cd $APP_ROOT && cabal clean && cabal install --only-dependencies && cabal configure && cabal build"
```

#### tasks/deploy-production.sh

Angel からWeb アプリケーションを起動するが、Angel 自体を `nohup` で起動する。

```sh
CONFIG_FILE="$APP_ROOT/config/angel.conf"
LOG_DIR="/var/log/yesod"
su - -s /bin/bash angel -c "nohup angel $CONFIG_FILE > $LOG_DIR/angel.stdout.log 2> $LOG_DIR/angel.stderr.log < /dev/null &"
```

リロードするときは、アプリケーションをビルドした後、Angel ではなくアプリケーションのプロセスを `kill` すると立ち上げ直してくれる。
