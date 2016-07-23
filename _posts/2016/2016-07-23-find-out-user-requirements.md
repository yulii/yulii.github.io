---
layout: post
title:  "「ユーザーの声」を聞いてみよう"
date:   2016-07-23 18:50:04 UTC+9
category: culture
tags: communication
---

_社内のエンジニア向けに書いたポエムから転載_

### 「ユーザーの声」を聞くのは難しい。

それでも、ユーザーの声を聞かないわけにいかない。エンジニアはユーザーの声を直接聞いてみたいと思う。でも、残念なことに良い結果にならないことの方が多い。

業績数値 (KPI) を追いかけて「機能提案」していく中で、きっと躓く気がするので僕の思うところをつらつらと書いておきます。無防備にユーザーと会話するのではなく、正しく論理武装して会話することが大事です。ただ、このスキルを習得するのには何年もかかると思います。なぜなら、それが正しいと分かるまで何年もかかるので（自分自身でも正しいのか、まだわかりません）。


## プロダクトの価値（製品要求）を知るための情報収集

プロダクトの価値（製品要求）、つまり「どんなモノを作ればよいか？」の参考になる情報は以下の3つがある。

- __ユーザーの要望__ :point_left: この投稿はココの話
    - ユーザーは、何が欲しいと思っているか？
- __マーケティング・PR メッセージ__
    - ユーザー (toC) に対して、製品をどのように説明するか？
- __セールストーク__
    - ユーザー (toB) に対して、製品をどのように説明するか？

ただし、これらは「プロダクトの現在価値」を反映するものであり「プロダクトの未来価値」に繋がるかどうかは別問題です。つまり「今の製品にどんな改良をすればよいか？」「どんな機能を追加すればよいか？」は、誰も教えてくれない。世の中に出してみなければ答えがわからない。


## 製品開発におけるエンジニアの役割

製品開発には大きく3つの役割がある

- __プロダクトマーケティングマネージャー (PMM)__
    - 世の中に向けて製品を語り、市場での製品の位置づけを明確にすること
- __プロダクトマネージャー (PM)__
    - 価値のある、使いやすい、実現可能な製品を定義すること
    - 「どんな製品を創るのか？ (What)」と「なぜ創るのか？ (Why)」を考える人
    - 状況によっては「いつまでに必要か？ (When)」を決めなければならない
- __エンジニア[^2]__
    - What を実現するためのHow を考える人

ユーザーの要望を理解するためには、プロダクトマネージャーの仕事の一つである製品要求仕様書 (PRD) の作成スキルが関係する。

[^2]: デザイナーもエンジニアと同様に「What をどのように実現するか？ (How)」を考える


## 「ユーザーの声」を聞いてみよう

「ユーザーの声」を聞いてプロダクトに反映するには「具体的な事実を抽象化するスキル」と「抽象的な要件を具体化するスキル」の2つが必要です。

言い換えると、

__ユーザーの要望（具体的な事実）__  
　　:arrow_down:  
__メンタル・モデルと構造に分解（抽象化）__  
　　:arrow_down:  
__製品要求定義（具体化）__

という変換を正しく行うスキルです。


## ユーザーの要望を理解するフレームワーク

「具体的な事実を抽象化するスキル」に関連するツールとして「氷山のモデル」があります。

![Iceberg Model](/img/posts/2016/2016-07-23-iceberg-model.png)

その要望が「なぜ出てきたのか？」を背景を理解し、その構造を分解してはじめて「要望を聞く」ことができる。僕が「構造」と言っているのはこのモデルにおける「構造」を指しています。


### ユーザーの要望に応えるステップ

1. __ユーザーの声は聞かない__
    - ユーザーは自分がいったい何が欲しいのか、わかっていない
2. __要望には「No」と言う__
    - 「〇〇が欲しい」と言われたものに反射的に「作ります (Yes)」とは言わない
3. __ユーザーが望む提案を出す__
    - ユーザーの要望の「構造」を捉えた「製品（機能、デザイン）」を提案する

ユーザーは「穴」が欲しいに、口では「ドリルが欲しい」と言う。言葉を鵜呑みにするとスタートから間違う。[事実と意見の区別](https://yulii.github.io/way-of-writing-20160129.html#section-5)して「事実」に着目するのが大切です。

ユーザーから「検索機能が欲しい」「Amazon みたいなレコメンドってできないの？」などと言われると、エンジニアは「技術的な実現可能性」を考えて「出来ます（作ります）」とつい反射的に言ってしまいます。

作るのは得意なのだからこそ、「ユーザーの声」を理解するための時間はゆっくり取れば良いと思う。そして、失敗を恐れずに提案（リリース）していくのがエンジニアの仕事だ。

## 参考

- [「顧客は自分が何が欲しいのかわかっていない」をわかりやすく例える方法](http://dqn.sakusakutto.jp/2012/03/post_46.html)
- [「なぜ」を繰り返すのはなぜか、システム思考の「氷山モデル」で考える](http://tannomizuki.hatenablog.com/entry/2015/06/25/000022)
- [第18章　製品仕様はどうあるべきかを考える - Inspired日本語版](https://inspiredjp.com/2011/02/25/chapter-18/)