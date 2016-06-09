---
layout: post
title:  "java.lang.OutOfMemoryError: PermGen space の対処法"
date:   2010-08-10 01:32:52 UTC+9
category: java
tags: eclipse tomcat
---

## java.lang.OutOfMemoryError: PermGen space

メモリが足りなくてすぐにTomcat が落ちる場合の対処法は、起動時にメモリ容量を指定する。

### Tomcat の起動パラメータ設定

#### Eclipse のTomcat プラグイン設定

ウインドウ > 設定 > Tomcat > JVM 設定 > JVM パラメータへ追加

以下のパラメータを設定する。

```
-XX:MaxPermSize=256m
-Xmx512m
-Xms256m
```

RAMの容量を考慮して、適宜メモリを割り当てる。

