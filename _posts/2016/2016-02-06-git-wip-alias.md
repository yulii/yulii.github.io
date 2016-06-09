---
layout: post
title:  "Git コマンドにWIP エイリアスを設定したら便利だった"
date:   2016-02-06 13:55:06 UTC+9
tags: ci git
---

試しに作ってみたら案外便利でした。WIP[^wip] のPull Request を作るとチームのみんなに自分の作業を視える化でき、場合によっては作業途中にアドバイスもらえたりします。

新しいブランチを切って、空のPull Request を作るのに2つやりたいことがあります。

- 空のコミットを作りたい
- まだコードの変更がないからCI を動かしたくない

これらの仕組みは用意されているので、それを使うだけですがコマンドを覚えたり、タイプするのが面倒なのでエイリアスでまとめてみました。

## 空のコミットの作り方

通常、何も変更がない状態ではコミットできません。 `--allow-empty` オプションを指定すると、変更がなくてもコミットを作ることができます。

```
git commit --allow-empty
```

## CI をスキップする

CI をGit のコミットに紐付けていると、自動でテストが実行されてしまいます。CircleCI やTravis などのサービスであればコメントに`[ci skip]`を含めると、そのコミットに対するCI の実行をスキップできます。

無駄にキューが積まれるとチームの他メンバーの作業にも影響するので、`[ci skip]`はかなり便利です。

- [Customizing the Build - Travis](https://docs.travis-ci.com/user/customizing-the-build/#Skipping-a-build)
- [Skip a build - CircleCI](https://circleci.com/docs/skip-a-build)


## WIP エイリアスを設定する

`.gitconfig` に `wip` というエイリアスを作りました。

```
[alias]
  wip = "commit --allow-empty -m '[ci skip] wip commit'"
```

これで `git wip` を実行すると空のコミットができ、コメントでCI実行をスキップする指定が入ります。

## WIP Pull Request を作る

以下のような流れで空のPull Request を作ります。

```
git checkout -b feature/user-login
git wip
git push
```

一連の流れをまとめたコマンドを作っても良いですが、別にしておいた方が使い勝手良さそうなのでいったんエイリアス設定するだけにしました。

## 参考

- [git commit --allow-empty を使った WIP PR ワークフロー](http://qiita.com/a-suenami/items/129e09f8550f31e4c2da)

[^wip]: Work In Progress の略。タスクが作業中、進行中であることを表す。
