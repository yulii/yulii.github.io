---
layout: post
title:  "CPU (コア、プロセッサ) の数を調べる @Linux"
date:   2013-02-16 09:10:44 UTC+9
category: unix
---

## コマンドで簡単にCPU の数を調べる方法

### 仮想コア数

~~~sh
cat /proc/cpuinfo | grep processor
processor     : 0
processor     : 1
processor     : 2
processor     : 3
processor     : 4
processor     : 5
~~~

Hyper-Threading (ハイパースレッディング) というカッコいい名前の奴が有効になっていると、物理的なコア数を別途調べる必要がある。


### 物理コア数

~~~sh
cat /proc/cpuinfo | grep "physical id"
physical id     : 0
physical id     : 0
physical id     : 0
physical id     : 0
physical id     : 0
physical id     : 0
~~~

`physical id` の値の種類が1つなので、物理CPU は1個

