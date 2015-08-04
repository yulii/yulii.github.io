---
layout: post
title:  "Linux でメモリの使用状況をチェックする"
date:   2013-03-06 14:43:12
category: unix
---

## Linux でメモリの使用量を調べるコマンド

Linux でメモリの使用量を調べるアレコレ

### free コマンド

現在のメモリ空き状況は `free＋buffers＋cached` で算出できる

```sh
$ free
             total       used       free     shared    buffers     cached
Mem:        192572     190944       1628      54912      20112     126848
-/+ buffers/cache:      43984     148588  <- ココを見る
Swap:        96384          0      96384
```

### top コマンド

```sh
top
```

top コマンドを起動してから “M” (大文字) すると消費メモリの順に表示される。

### ps コマンド

`--sort` オプションを使うと、指定した項目でソートできる。

#### RSSでソート

```sh
ps aux --sort -rss
```

#### VSZでソート

```sh
ps aux --sort -vsize
```

