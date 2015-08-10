---
layout: post
title:  "Action Mailer で覚えておくと便利な機能"
date:   2015-08-08 20:12:46 UTC+9
category: ruby
tags: rails
---

## Rails Console でメール送信確認

メール送信自体のテストする際に、メーラーやビューを定義しなくても `ActionMailer::Base` でそのまま送信できる。
SMTP サーバーの接続先を変更したり、ミドルウェアの変更に伴う問題の切り分けなどで使うと便利。

```ruby
ActionMailer::Base.mail(to: 'to@example.com', from: 'from@example.com', subject: '件名', body: 'メール本文').deliver
```

もちろん、以下のようにActionMailer を定義してあれば、コンソール上でただ実行すれば良い。

```ruby
class TestMailer < ActionMailer::Base
  default from: 'from@example.com'

  def hello
    mail(to: 'to@example.com', subject: '件名', body: 'メール本文')
  end
end
```

## perform_deliveries オプション

`perform_deliveries = false` するとメール配信を抑制できる。
機能テストなどであれば、 `config/environments/test.rb` などの環境設定ファイルで問題ない。


ただ、特定条件下でメール送信を止めたいときは、`perform_deliveries = false` すると良い。
共通の親クラスを定義し、コールバックの `after_action` で制御すると便利。

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  after_action :prevent_delivery

  private
  def prevent_delivery
    message.perform_deliveries = false if @user.nil?
  end
end
```

コールバックのメソッド内で、自身のメールオブジェクトは `message` 変数で参照する。

## ActionMailer のインスタンスメソッドをテストする

`ActionMailer::Base.new` できないので、インスタンスメソッドを直接テスト書くのが難しい。
ActionMailer の機能ではないが、 `new` の代わりに `allocate` が使える。

```ruby
describe ApplicationMailer do
  describe '#prevent_delivery' do
    subject { mailer.perform_deliveries }

    # allocate でオブジェクトを取得できる
    let(:mailer) { ApplicationMailer.allocate }

    before do
      # 本来コールバックで呼ばれる部分をMock 化
      allow(mailer).to receive(:message).with(no_args).and_return(mailer)
    end

    context 'when user is present' do
      before do
        mailer.instance_variable_set(:@user, User.new)
        mailer.send(:prevent_delivery)
      end

      it { is_expected.to eq(true) }
    end

    context 'when user is nil' do
      before do
        mailer.send(:prevent_delivery)
      end

      it { is_expected.to eq(false) }
    end
  end
end
```

今回の例はコールバックで呼ばれる予定のインスタンスメソッドなので、Spec 内でテスト用のActionMailer クラスを定義しても良い。

```ruby
let(:mailer) do
  Class.new(ApplicationMailer) do
    default(from: 'from@example.com')

    def spec
      mail(to: 'to@example.com', subject: 'subject', body: 'body')
    end
  end
end
```

