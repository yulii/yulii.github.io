---
layout: post
title:  "お問い合わせ対応フローと分類整理"
date:   2020-10-20T02:27:01+0900
category: business
tags: customer-service
---

プロダクトに関するお問い合わせ対応について基本的なことを整理してみた。

## お問い合わせ対応の流れ

![Remark](/img/posts/2020/2020-10-20-inquiry-response-flow.png)

カスタマーサポートを立ち上げ初期はプロセスをなるべく単純化する。実際のお問い合わせ内容を月1回程度の頻度で振り返りして、徐々に細分化しながら、具体的な業務手順（マニュアル）を整えると良い。

まずは『質問』『不具合』『要望』の3つにお問い合わせを分類するところから始めるのが良いと思う。


- __質問__
    - プロダクトの使い方に関する疑問や操作方法の確認
- __不具合__
    - 想定された操作において想定外の動作が起きた事象（仕様と異なるシステムの挙動）
    - 再現する手順が判明していること
- __要望__
    - プロダクトの機能追加や変更に関わる意見


### 『質問』の対応

質問はカスタマーサポートが単独で解決できる可能性が高い。素早く答えて利用者の問題を解決することは当たり前として、 __FAQなど利用者がセルフ解決できる仕組みの更新を日常的な業務手順に組み込むのが大切です。__ 利用者からのお問い合わせ対応が最優先なので「あとでやろう」はあてにしない方が良い。お問い合わせ対応は、仕組みの更新作業を含めて一連の流れとした方が良い。1件ずつ毎回やれなくても、1日の終わりにその日のお問い合わせをまとめて振り返りFAQを整えるのも一案です。

質問の中にはプロダクトで解決した方が良い内容も含まれます。導線やUIの調整で似た様な事象で困る利用者を減らすことができます。 __プロダクト部門への共有は解決方法ではなく、利用者からのお問い合わせ内容を加工せずに原文で伝えることが重要です。__ 質問が出た利用者の置かれている環境や状況について補足情報があると問題を解決する手段が検討しやすくなります。

ただし、誤操作によるリスク回避で意図的に操作性を下げた方が良い場合もある。例えば、業務システムにおいて削除操作が利用者の意図に反して実行されてしまうと、削除方法のお問い合わせが頻出する以上の問題となる可能性がある。


### 『不具合』の対応

不具合が起きた場合、カスタマーサポートが単独では対処できない。プロダクト部門やエンジニアに協力を仰いで解決していく必要がある。問題解決を急ぐとともに、発生事象の情報をまとめて、影響を受ける利用者に対して迅速に広報することも重要。

おおむね以下の情報を揃えておくと原因特定までの時間が短縮でき、結果として問題解決までのスピードアップにつながる。

- __利用環境__
    - 利用端末とOS
        - PC (Windows / Mac)
        - タブレット
        - スマートフォン（iPhone, Android）
- __契約プラン__
    - 契約プランにより利用可能な機能が異なる
- __再現手順__
    - 問題が起きるまでに操作した手順
    - 問題が起きたときの画面表示（表示されたエラーメッセージ、スクリーンショットなど）

また、 __利用環境はお問い合わせ管理ツール（Zendesk やIntercom など）の機能で視える化したり、アクセスログとして自動的に取得できる様にあらかじめエンジニアに環境を整えてもらうと良い。__

余談だが、エンジニア視点でやるべきは、エラーの検知で利用者のお問い合わせがなくても問題に気がつき不具合を解消できる状態にしておくこと。エラーしたことが利用者に適切に伝わることもユーザー体験の一部であるため、エラーメッセージは適切な表示にする。ついでに、お問い合わせの誘導をいれることで、原因調査に役立つ情報を利用者からフィードバックしてもらいやすくすることも検討しておくと良い。


#### 不具合の根本解決までのサポート

不具合の根本解決には時間がかかる場合には、利用者への一次対応を工夫する必要がある。利用者への説明として『影響範囲』『代替手段』『解決までの見込み』を整理しておく。

- __発生事象による影響範囲__
    - 不具合に関する情報は、影響を受ける利用者のみに通知できればベスト
        - 大抵は想定していない範囲に対して事件が起きるので難しい場合が多いので、情報を受け取った利用者が自分自身に関係があるか否かがわかるように明記しておく必要がある
- __不具合を回避する代替手段__
    - 恒久的な問題解決にはプロダクトの修正が必要になるため、問題を回避できる代替手段があれば利用者に伝えると良い
- __問題が解決する想定時間__
    - 解決までの概ねの時間がわかれば、あらかじめ利用者に伝えると良い
        - 見通しが立たない場合、解決予定時刻の代わりに次回の告知時間を提示するのも良い


### 『要望』の対応

利用者からいただいた要望は不具合の対応と同様に時間がかかる場合が多い。どの利用者から、どんな要望をいただいたのか記録を管理し、実現された際には個別連絡ができる様にしておくと良い。仮に、お問い合わせから1年以上経っていて、要望した本人が内容を忘れていてても、最終回答として要望に対応した旨を伝えることが大事。なぜなら、質問と不具合とは異なり、要望は長期的な利用者との関係性に繋がるため。
