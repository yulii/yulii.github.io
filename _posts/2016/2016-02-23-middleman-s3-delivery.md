---
layout: post
title:  "Middleman とAmazon S3 でLP 改善インフラを作る"
date:   2016-02-23 17:55:06 UTC+9
tags: git
---

ランディングページの改善はKPI に直結する大事な施策です。A/B テストなどで、ボタンの色を比較したり、フォームのラベル名を変えてみたり、ガラッとレイアウトを変えてみたり、とにかく数多く試すことが求められます。

ただ、フロントエンドの作業がほとんどなので、できればエンジニア以外のリソースでまかないたいなと思いました。本体サービスから切り出してフロントエンドエンジニア（もしくはデザイナー）で作業が完結できると良いなーと思い、Amazon S3 に配置する仕組みを考えました。かれこれ2年近く運用していますが、おおむね良い感じです。 :blush:


## Amazon S3 デプロイ構成

![Middleman build & upload S3](/img/posts/2016/2016-02-23-middleman-s3.png)

全体像としては、Git のブランチ名とS3 のディレクトリ名を一致させるように運用しています。このルールはデプロイスクリプトの中で自動的に一致するように管理されています。今のところ、デプロイがローカルマシンなので `Git => CircleCI => S3` みたいな自動化をしてもよいと思います。

新しいLP 改善の施策は新しいブランチを切り作業しますが、LP は使い捨てになることがほとんどなので `master` ブランチへのマージはしないです。使い捨てを前提に、通常のコード管理とは違うワークフローになっています。

LP のコーディングはMiddleman を利用して、Slim で書いています。デザイナーがSlim でコーディングできたことのでMiddleman を使いました。あと[middleman-imageoptim](https://github.com/plasticine/middleman-imageoptim)などで画像の最適化処理などをビルド時に設定できるので使い勝手が良かったです。

## 使っているツール

- [Middleman](https://middlemanapp.com/)
    - HTML/CSS 生成と画像最適化処理のために利用しています
- [S3cmd](http://s3tools.org/s3cmd)
    - ローカルマシンからAmazon S3 のAPI を利用するためにインストールしています

A/B テスト自体はGoogle Analytics を使ったりしています。

## ビルドとデプロイ

こんな感じのデプロイスクリプトを用意しています。

```
#!/bin/sh
S3_BUCKET="yulii.github.io" # S3 のバケット名を入れてください

BUILD_DIR="build/"
BUILD_CMD="bundle exec middleman build"

CURRENT_BRANCH=`git symbolic-ref HEAD 2>/dev/null | sed -E 's/refs\/heads\///g'`
VERSION=${1:-$CURRENT_BRANCH}
DEPLOY_URL="s3://$S3_BUCKET/$VERSION/"
DEPLOY_CMD="s3cmd put -r"

if [ -z $VERSION ]
then
  echo "ERROR: 'git branch' not found"
  exit 1
fi

echo "[EXECUTE] $BUILD_CMD"
$BUILD_CMD

if [ $? -eq 1 ]
then
  exit 1
fi

cat << _EOT_

Deployment Configuration:
  Refs Name: $CURRENT_BRANCH -> $VERSION
  Deploy: $BUILD_DIR => $DEPLOY_URL

_EOT_

printf "Start uploading? [y/N] "
read FLG
echo

if [ $FLG = "y" ]
then
  echo "[EXECUTE] $DEPLOY_CMD $BUILD_DIR $DEPLOY_URL"
  $DEPLOY_CMD $BUILD_DIR $DEPLOY_URL
fi
```

デプロイ自体は `middleman build` して `s3cmd put` するだけの作りになっています。アップロードする先のS3 のパスを現在作業中のGit ブランチ名から補完しています。本番反映されるので、一応の確認が入るようになっています。

ちょっとイケてないところは、 `git push` に連動していないので commit & push とデプロイ自体は別作業になるので忘れずに。

## まとめ

### 良いところ

- デザイナー工数だけでLP 改善の施策をぐるぐる回せる :recycle:
- 本体サービスのデプロイと関係なく検証を進められる

### 改善の余地があるところ

- ブランチがとっ散らかって困る・・・
    - 使わなくなったブランチとS3のファイルを削除するフローがあると良いかも
- トラフィック量が多くなるとS3 のコストがそこそこかかる :money_with_wings:

### 制約条件

- S3 に配置するので動的なものが作れない

## 参考

- [Amazon S3による静的Webサイトホスティング](http://www.slideshare.net/horiyasu/amazon-s3web-27138902)
- [Middlemanで生成したサイトをAmazon S3で運用する](http://blog.qnyp.com/2013/05/21/middleman-sync/)
