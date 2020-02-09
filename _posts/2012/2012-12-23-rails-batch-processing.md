---
layout: post
title:  "rails runner を使わないバッチ処理を実装してみた"
date:   2012-12-23T03:10:59+0900
category: engineering
tags: ruby rails
---

`rails runner` みたいに環境を読み込んでバッチ処理したい。けど、単独で処理するので `lib/` とかに入れて Rails アプリケーション自体にはロードしたくない。的なノリで Batch 処理を作ってみた。

## Rails 環境を読み込んでバッチ処理がしたい！

基本的な流れは、`require 'config/application'` して、`Rails.application.require_environment!` した後に、やりたいことを書くだけ。

## バッチ処理用の環境設定

必要な読み込み処理を共通化するために別ファイル化しておく。ついでに環境変数の設定処理も入れた。
ファイル名は `script/batch/config.rb` にして置いた。

```ruby
#!/usr/bin/env ruby
# Has to set the RAILS_ENV before config/application is required
if ARGV.first && !ARGV.first.index("-") && env = ARGV.shift # has to shift the env ARGV so IRB doesn't freak
  ENV['RAILS_ENV'] = %w(production development test).detect {|e| e =~ /^#{env}/} || env
end
require File.expand_path('../../../config/application',  __FILE__)
Rails.application.require_environment!

class Batch; end
```

## バッチ処理の実装

共通化した `config.rb` ファイルを読み込んで必要な処理を記述する。ファイル名は `script/batch/hello.rb` とした。

```ruby
#!/usr/bin/env ruby
require File.expand_path('../config',  __FILE__)

class Batch::Hello
  def self.execute
    puts "HELLO!"
  end
end
Batch::Hello.execute
```

## バッチ処理の実行

動かしたい環境を指定して実行するだけ。環境の指定がなければ development で動く。

```sh
bundle exec ruby script/batch/hello.rb production
```

デザイン変わって画像を再リサイズしないと的な処理とか。データパッチをあてるだけの処理とかで、Rails のModel を使ってごにょごにょしたい時に、本体アプリの起動時には読み込ませず、単独処理したい場合に利用している。
