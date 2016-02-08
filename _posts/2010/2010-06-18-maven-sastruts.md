---
layout: post
title:  "Maven から SAStruts のプロジェクトを新規作成"
date:   2010-06-18 14:27:02 UTC+9
category: java
tags: eclipse maven
---

## SAStruts プロジェクトの雛形生成

~~~
mvn archetype:generate -DarchetypeRepository=https://www.seasar.org/maven/maven2/ \
    -DarchetypeGroupId=org.seasar.sastruts \
    -DarchetypeArtifactId=sa-struts-archetype -DarchetypeVersion=1.0.4-sp7 \
    -DgroupId=web.app -DartifactId=web -Dversion=1.0-SNAPSHOT
~~~

### Eclipse プロジェクトに適応させる

プロジェクトのROOT ディレクトリ内で、`eclipse:eclipse` タスクを実行する。

~~~
mvn eclipse:eclipse
~~~

m2eclipse プラグインの場合は `eclipse:m2eclipse` を利用する。

