---
layout: post
title:  "Docker + Serverspec + Infrataster を使ってCircleCI 上でインフラのテストを実行する"
date:   2016-06-08 20:43:06 UTC+9
category: server
tags: ci
---

## TL;DR

- Itamae レシピを Docker + Serverspec でテストする
- テストのためにDocker コンテナ上で `sshd` を実行したくない
- CircleCI は `docker exec` 使えないので `lxc-attach` を使う

おまけで Infrataster のテスト方法も記載しています。具体的な設定内容などはGitHub リポジトリ [yulii/continuous-hardening #51e1618](https://github.com/yulii/continuous-hardening/tree/51e16181ceaf73e8e91ca1ce9ddea615a747cf3d) を見てください。Itamae レシピやServerspec とInfrataster の内容自体は適当ですが・・・。


## ディレクトリ構成

この記事の設定は下記のディレクトリ構成で実行しています。

~~~
% tree .
.
├── LICENSE.txt
├── README.md
├── circle.yml
├── cookbooks
│   └── nginx
│       ├── default.rb
│       ├── files
│       │   └── etc
│       │       └── nginx
│       │           └── conf.d
│       │               ├── default.conf
│       │               └── secure.conf
│       └── templates
│           └── etc
│               └── nginx
│                   └── nginx.conf
├── infrataster
│   ├── Dockerfile
│   └── spec
│       ├── sample_spec.rb
│       └── spec_helper.rb
├── roles
│   └── ci.rb
└── serverspec
    ├── Dockerfile
    ├── Rakefile
    └── spec
        ├── localhost
        │   └── sample_spec.rb
        ├── matchers
        │   └── have_http_header.rb
        └── spec_helper.rb
~~~

## ローカル環境 (OS X) からテストを実行する

### 必要なモノをインストールする

- docker
- docker-machine
- docker-machine-driver-xhyve

Homebrew などで適宜インストールしておいてください。
既にVirtualBox などを使っている場合は xhyve じゃなくても良いです。

ローカル環境 (OS X) は、下記のバージョンで実行しています。

~~~
% docker -v
Docker version 1.10.3, build 20f81dd

% docker-machine -v
docker-machine version 0.6.0, build e27fb87
~~~

CircleCI 上のホストでは、下記のバージョンで実行されています。

~~~
ubuntu@box723:~$ docker --version
Docker version 1.8.2-circleci-cp-workaround, build 4008b9c-dirty
~~~

_cf. [OS XのネイティブHypervisorを使うxhyveと、ネイティブDockerを立ち上げるdocker-machine-driver-xhyveを作った話](http://qiita.com/zchee/items/cb4bb68a0aab12dfa2c1)_

### Docker コンテナを作成する

Docker Machine を作成して、コンテナを使う準備をします。スペックは適宜調整してください。

~~~
docker-machine create ci\
  --driver xhyve\
  --xhyve-memory-size 2048\
  --xhyve-disk-size 5120\
  --xhyve-cpu-count 1\
  --xhyve-experimental-nfs-share;
~~~

Docker イメージをダウンロードする際にDNS が欲しいので適当に突っ込みます。

~~~
docker-machine ssh ci "sudo echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
~~~

あとは、Docker コマンドを扱えるように `docker-machine env ci` を確認して環境変数を設定してください。

### コンテナを使ってテストを実行する

プロビジョニングのためにSSH サーバーを立てる場合、プロビジョニング用のSSH ユーザや鍵の追加でサーバー構成に差分が出るため、コンテナ内でローカルホストに向けて Itamae を実行しています。

SSH サーバーの構成差分が特に気にならなければ、SSH サーバーを立てる方法でも良いと思います。[Docker コンテナ的にはSSH サーバー立てるな](http://postd.cc/docker-ssh-considered-evil/)ということもありますが、テストのためのコンテナなら良いと思います。

SSH 経由で動かすなら下記の記事などを参考にすると良いと思います。
[CircleCI + Docker による Itamaeレシピの継続的インテグレーション](http://qiita.com/kotaroito/items/e5490b4188c41c07bba0)

#### コンテナを定義する

コンテナ内で Itamae とServerspec を動かすため、Ruby と合わせてインストールします。Itamae のレシピは `COPY` でコンテナ内に配置します。

~~~
FROM alpine

WORKDIR /usr/local/provisioning

RUN apk update && apk upgrade
RUN apk add --no-cache ruby ruby-io-console ruby-json
RUN gem install itamae rake serverspec --no-ri --no-rdoc

COPY cookbooks cookbooks
COPY roles roles
COPY serverspec/Rakefile Rakefile
COPY serverspec/.rspec .rspec
COPY serverspec/spec spec

CMD ["tail", "-f", "/dev/null"]
~~~

コンテナ自体は特にプロセスを実行する必要が無いので、代わりに `tail -f /dev/null` を実行させてテスト実行まで待機させています。 `RUN` はなるべく1行にまとめて実行したほうが良いですが、読みづらいので分けて書いておきます。

_cf. [Alpine Linux で軽量な Docker イメージを作る](http://qiita.com/pottava/items/970d7b5cda565b995fe7)_

#### Itamae + Serverspec を実行する

イメージをビルドして動かした後、 `docker exec` を使ってコンテナ上で Itamae とServerspec を動かすだけです。

~~~
docker build -t serverspec -f serverspec/Dockerfile --no-cache .
docker run --name ci -it -d serverspec
docker exec -it ci /bin/sh -c 'itamae local roles/ci.rb'
docker exec -it ci /bin/sh -c 'rake spec'
~~~

## CircleCI でテストを実行する

CircleCI は `docker exec` に対応していないので、 `lxc-attach` を使います。ローカルで構築した構成はそのまま使えるので、コマンドだけ置き換えればOK です。

_cf. [Docker Exec - CircleCI](https://circleci.com/docs/docker/#docker-exec)_

~~~
machine:
  services:
    - docker

dependencies:
  pre:
    - docker build -t serverspec -f serverspec/Dockerfile --no-cache .
    - docker run --name ci -it -d serverspec
test:
  pre:
    - sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' ci)" -- /bin/sh -c 'cd /usr/local/provisioning && itamae local roles/ci.rb'
  override:
    - sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' ci)" -- /bin/sh -c 'cd /usr/local/provisioning && rake spec'
~~~

詳細はよくわかっていないのですが、直接LXC (`lxc-attach`) を使うとDockerfile に定義した `WORKDIR` が反映されないので `cd` しています。


## Infrataster で振る舞いテストを実行する

Serverspec はサーバー内部のソフトウェアやファイルのテストですが、Infrataster は外部からサーバーの振る舞いを検証するツールです。詳しいことは公式サイト [ryotarai/infrataster](https://github.com/ryotarai/infrataster) などを参照してください。

_cf. [Infratasterでリバースプロキシのテストをする](http://techlife.cookpad.com/entry/2014/11/19/151557)_

### コンテナの構成図

- サーバー設定のテストを実行するコンテナ
    - Itamae とServerspec が動作する環境
- サーバーの振る舞いテストを実行するコンテナ
    - Infrataster が動作する環境

![Docker Containers](/img/posts/2016/2016-06-08-docker-containers.png)


### Infrataster 用のコンテナを定義する

Infrataster を実行できれば良いので、必要なソフトウェアをインストールして `rspec` を実行します。

~~~
FROM alpine

WORKDIR /usr/local/provisioning

RUN apk update && apk upgrade
RUN apk add --no-cache g++ libxml2-dev make ruby ruby-dev
RUN gem install infrataster --no-ri --no-rdoc

COPY infrataster/.rspec .rspec
COPY infrataster/spec spec

CMD ["rspec"]
~~~


### ローカル環境 (OS X) で確認する

`docker inspect` でDocker コンテナのIP アドレスを取得してInfrataster を実行します。

~~~
docker build -t serverspec  -f serverspec/Dockerfile  --no-cache .
docker build -t infrataster -f infrataster/Dockerfile --no-cache .
docker run --name ci -it -d serverspec
docker exec -it ci /bin/sh -c 'itamae local roles/ci.rb'
docker exec -it ci /bin/sh -c 'rake spec'
docker run --add-host spechost:$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ci) -it infrataster
~~~

Infrataster には `spechost` という名称でテスト対象のホスト名を記述しています。`docker run` する時にIP アドレスを `--add-host` オプションで渡しています。


### CircleCI でテストを実行する

CircleCI 上で試したところ、 `docker inspect` から取得したIP アドレスでは繋がらなかったので `circle.yml` には手を加えています。

~~~
machine:
  services:
    - docker

dependencies:
  pre:
    - docker build -t serverspec  -f serverspec/Dockerfile  --no-cache .
    - docker build -t infrataster -f infrataster/Dockerfile --no-cache .
    - docker run --name ci -it -d serverspec
test:
  pre:
    - sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' ci)" -- /bin/sh -c 'cd /usr/local/provisioning && itamae local roles/ci.rb'
  override:
    - sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' ci)" -- /bin/sh -c 'cd /usr/local/provisioning && rake spec'
    - docker run --add-host spechost:$(sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' ci)" -- /bin/sh -c 'ip -f inet -o addr show eth0 | cut -d\  -f 7 | cut -d/ -f 1') -it infrataster
~~~

読みづらいですが、IP アドレスをテスト対象のホストにログインして `ip` コマンドから取得します。

~~~
ip -f inet -o addr show eth0 | cut -d\  -f 7 | cut -d/ -f 1
~~~

`docker exec` が使えないので、上記のコマンドを `lxc-attach` 経由で実行します（結果的にコマンドが長くなり読みづらい :fearful: ）。


## Infrastructure as Code の構想

今回はCircleCI 上で継続的にテストを実行するため、Docker イメージには軽量なAlpine Linux を指定しています。実際の運用には違うOS を使う場合はなるべく合わせたほうが良いです。

AWS ベースを前提にしていますが、以下の様な形で軽量にCI を回しつつ、本番環境との差異をリスクヘッジしようとしています。

1. Terraform でAWS リソース（インフラ）の定義する
2. Itamae でサーバー設定の定義する
    - CircleCI 上でServerspec を動かす (Alpine Linux)
3. Terraform + Itamae で作成されたサーバーからAMI 作成する
    - AMI 生成前に、Infrataster でサーバーとしての振る舞いを確認する
4. AMI からサーバーを起動してアプリケーションをデプロイする
    - 必要に応じて Infrataster で振る舞いテストや手動テストを実施する


AMI を作成する際にInfrataster でテストすれば本番環境と同じOS になるので、Serverspec で検知できなかった環境差異の問題が見つかるはず。たぶん。

というわけで、実際の運用ではCircleCI 上でInfrataster は動かさないです。 :disappointed:
