---
layout: post
title:  "コマンド実行結果のdiff を取るといろいろ捗る"
date:   2015-06-27 23:08:12 UTC+9
category: unix
tags: dns
---

たまに必要になる diff コマンドのTips メモです。

## コマンド実行結果のdiff を取る

bash なら `<(command)` の形式で `diff` にコマンドの結果を入力できる。
シェルスクリプトとして記述する場合は `set +o posix` を指定すると使える。

```sh
$ diff <(echo "hoge") <(echo "fuga")
1c1
< hoge
---
> fuga
```

bash 以外でも `command1 | (command2 | diff /dev/fd/3 -) 3<&0` の形式で同様の処理が可能です。

```sh
echo "hoge" | (echo "fuga" | diff /dev/fd/3 -) 3<&0
1c1
< hoge
---
> fuga
```

`command1` の結果は `3<&0` により、ファイルディスクリプタ `/dev/fd/3` へ出力される。
ハイフン `-` は標準出力を受け取るので `command1` と `command2` の出力結果の diff が実行結果になる。

## DNS レコードを比較する

NS 移行の際に、DNS レコードの設定が間違っていないか確認するために diff してみる。
結論から言うと、新旧のNS へレコードを問い合わせて比較するだけ。

```sh
diff\
  <(dig @ns-before.example.com example.com a +short | sort)\
  <(dig @ns-after.example.com  example.com a +short | sort)
```

### dig コマンドでDNS レコードを確認する

余計な出力を省略するため `+short` を指定する。あとは問い合わせしたいNS とレコードを指定すれば良い。

```sh
dig @ns.example.com example.com a +short
```

複数の値が設定されている場合があるので、 `sort` して差分が出ないようにして `diff` へ渡すと設定内容に問題が無いかチェックできる。


