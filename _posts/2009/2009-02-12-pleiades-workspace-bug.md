---
layout: post
title:  "Eclipse (Pleiades) が起動しない時の処方箋"
date:   2009-02-12 04:53:18 UTC+9
tags: eclipse
---

## Pleiades によって Eclipse が起動しない

エラーメッセージ (eclipse/configuration 内のログファイル)

```
!SESSION Wed Feb 11 11:52:16 JST 2009 ------------------------------------------
!ENTRY org.eclipse.equinox.launcher 4 0 2009-02-11 11:52:16.437
!MESSAGE Exception launching the Eclipse Platform:
!STACK
java.lang.NoClassDefFoundError: Could not initialize class
jp.sourceforge.mergedoc.pleiades.aspect.resource.DynamicTranslationDictionary
    at jp.sourceforge.mergedoc.pleiades.aspect.TranslationTransformer.destroy
        (TranslationTransformer.java:173)
    at jp.sourceforge.mergedoc.pleiades.aspect.LauncherTransformer.destroy
        (LauncherTransformer.java:192)
    at org.eclipse.equinox.launcher.Main.basicRun (Main.java:448)
    at org.eclipse.equinox.launcher.Main.run (Main.java:1173)
```

Pleiades のバグでワークスペースの切り替えでワークスペース名が訳されてしまうらしい。

### 解決策1

`eclipse.exe -clean.cmd` から起動する。Eclipse SDK やプラグインが使用しているキャッシュやレジストリを削除し、再作成してくれます。

#### コマンドプロンプトから clean オプションで起動する場合

```
eclipse -clean
```

### 解決策2

`eclipse/configuration` の `jp.sourceforge.mergedoc.pleiades` を削除

