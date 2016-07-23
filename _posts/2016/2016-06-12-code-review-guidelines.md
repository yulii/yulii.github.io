---
layout: post
title:  "コードレビューの目的と心構え"
date:   2016-06-12 23:09:47 UTC+9
category: culture
tags: code-review
---

コードレビューを実践する中でバランス感覚が難しいと思い、自分なりにコードレビューの目的をまとめてみました。具体的なコードレビューのやり方を規定するものではなく1つの指針です。なので、アーキテクチャ/デザイン（DRY か？ 単一責任か？）やスタイル（メソッド名や変数名は適切か？）のチェックリストではないです。

## コードレビューの目的

個人的な意見ですがコードレビューの目的は、

__「コードの共同所有 (Collective Code Ownership)」__

だと考えています。

以下はあくまでもコードレビューを通して発生する副産物であり、コードレビューの目的ではないと思っています。

- ソフトウェア品質の向上
    - コードのスタイルを整える
    - バグを見つける
    - 技術的負債となり得るコードがないかを確認する
- スキルの向上やナレッジの共有
    - 担当者の技術スキルの把握
    - 他人のコードを読んで学びや発見を得る

ソフトウェアは読みものではなくユーザーに使ってもらうものなので、「良いコード」を目的にリリースを妨げるような過剰なレビューは避けたいと思っています。現実的には「良いコード」と「コードの共同所有」は表裏一体かもしれないですが。


### 「コードの共同所有」の実践

- __"サービス"__ をより良くするために自分の書いたコードをチームに共有しよう
- 誰の書いたコードであっても、チーム全員が断りなく修正を行うことができる
- 自ら見つけた課題は自ら解決し、Pull Request を送ること
- 賞賛は個人に、非難はコードに
- コードを書いた人と比べて技術や仕様に詳しくなくてもレビューに参加すること


## コードレビューの心得

すべては __"サービス"__ をより良くするための __"意見"__ として受け入れよう！


### コードレビューしてもらう人

- コメントをくれた人に感謝しよう :bow:
- 目的（なぜ、このコードが必要なのか？）をレビューする人へ完結に伝え、__無駄な情報は捨てよう__
    - コードも説明も少なくて済む方が良い（長いコードと長い説明は読まれない）
- 今直せるものは今直そう
    - コードレビューを依頼する前に、あらためて自分でコードレビューしてみよう
    - レビューに対して「あとで修正しよう」と思ったなら、「今すぐに修正できる方法はないか？」をもう一度考えてみよう
- __コードに責任を持つのはあなたです！__
    - 自分より詳しい人にレビューして貰ったから大丈夫と思うのはやめよう
- コードに責任が持てるならマージしよう :+1:

_無責任なコミットを抑止するため「コード」は共有しても「責任」は共有すべきではないと思います（共同所有の一部例外）。_


### コードレビューをする人

- 良いコードを書いてくれた人に感謝しよう :bow:
- コードの誤りを指摘することだけがあなたの仕事ではない
- コードを書く人の邪魔をしてはいけない
    - __"コードを良くすること"__ と __"ユーザー価値を増やすこと"__ のバランスを考えよう
    - コメントには __[MUST]__ や __[WANT]__ などの濃淡を付けましょう
- 好き嫌いで修正させるのはやめよう
- LGTM :+1: でレビューが終わったことを伝えよう


### コードレビューに期待してはならないこと

- レビューする人が動作確認（テスト）してくれること
- レビューする人がコードの誤り（バグ）を見つけてくれること
- 自分より技術や仕様に詳しい人がレビューしてくれること


## 補足：もしも、コードレビューが不公平だと感じたら・・・

- 信頼とコミュニケーションは反比例する
    - レビューが厳しい（コメントが多い）のは心配されているだけです
- コードの複雑さとコミュニケーションは比例する
    - 変更点の意図が理解できないコードは書き直すか、それ相応の説明が必要です
    - 規模が大きく、差分が多い場合は、それ相応の説明が必要です
    - 「コードのにおい」が漂ってくる時はたくさんのコメントがつくかもしれない :eyes:


## 参考

- [コードレビュー - プログラマが知るべき97のこと](http://xn--97-273ae6a4irb6e2hsoiozc2g4b8082p.com/%E3%82%A8%E3%83%83%E3%82%BB%E3%82%A4/%E3%82%B3%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%92%E3%82%99%E3%83%A5%E3%83%BC)
- [コードレビューに費やす時間を短くする](http://techlife.cookpad.com/entry/2015/03/30/174713)
- [コードの共同所有に弱点はあるか？](https://www.infoq.com/jp/news/2008/05/weaknesses_collective_code)