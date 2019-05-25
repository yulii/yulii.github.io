---
layout: post
title:  "Capistrano のデプロイ実行を通知するGem を作った"
date:   2015-08-13 21:01:08 UTC+9
category: engineering
tags: ruby ci
---

今のところ、Webhook にしか対応していない。とりあえず、Slack は連携できます。
ソースは[GitHub](https://github.com/yulii/capistrano-hook) を参照ください。

## Gem の使い方

### インストール方法

`Gemfile` に下記を追加する。

```ruby
gem 'capistrano-hook'
```

`Capfile` に下記を追加する。

```ruby
require 'capistrano/hook'
```

### Slack への通知設定

[Incoming Webhook Integration](https://my.slack.com/services/new/incoming-webhook/) から通知用のIntegration を作成する。
作成した後に発行される Webhook URL を `:webhook_url` に指定する。
定義するファイルは `config/deploy.rb` でも個別環境ごとの `config/deploy/production.rb` などでも良い。

```ruby
set :webhook_url, 'https://hooks.slack.com/services/XXXXXXXX'
```

各デプロイタスクで通知が必要な場合に適宜下記の変数を定義する。
変数を定義しなければ通知はスキップされます。

設定するハッシュの内容はSlack のAPI ドキュメント [Incoming Webhooks](https://api.slack.com/incoming-webhooks) を参照ください。

#### デプロイ開始時の通知設定

```ruby
set :webhook_starting_payload, {
  username:   'Capistrano',
  icon_emoji: ':{{ "monkey_face" }}:',
  text:       'Now, deploying...'
}
```

#### デプロイ終了時の通知設定

```ruby
set :webhook_finished_payload, {
  username:   'Capistrano',
  icon_emoji: ':{{ "monkey_face" }}:',
  text:       'Deployment has been completed!'
}
```

#### デプロイ失敗時の通知設定

```ruby
set :webhook_failed_payload, {
  username:   'Capistrano',
  icon_emoji: ':{{ "monkey_face" }}:',
  text:       'Oops! something went wrong.'
}
```

Hubot などを使って通知をしても良いが、Incoming Webhook を使うとSlack のチャンネル名を変更するときもSlack 側の変更だけで済むので楽だと思う。


## 通知の仕組み解説

Capistrano のデプロイフローにあわせて通知用のタスクをフックして実行しています。

### Capistrano のデプロイフロー

`capistrano-hook` が利用しているのは下記の3つのフローです。

- `deploy:starting`
    - デプロイ開始時に実行される事前処理タスク
- `deploy:finishing`
    - デプロイ終了時に実行される事後処理タスク
- `deploy:failed`
    - デプロイ失敗時に実行されるタスク

_cf. [Capistrano - Flow](http://capistranorb.com/documentation/getting-started/flow/)_


### Capistrano のBefore / After Hooks

Capistrano のタスクに対して、`before`, `after` フックを定義できます。
`capistrano-hook` は下記のタスクをフックしています。

```ruby
before 'deploy:starting',  'webhook:post:starting'
after  'deploy:finishing', 'webhook:post:finished'
after  'deploy:failed',    'webhook:post:failed'
```

`webhook:post:*` のタスクは `capistrano-hook` 内で定義しているタスクです。


## もやもや

Capistrano タスクのテストはどうしたら良いのか？

`capistrano-bundler` や`capistrano-rbenv` などを読んだけど、テストが無かった :disappointed_relieved:
