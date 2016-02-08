---
layout: post
title:  "TeX で PDF ファイルを生成する"
date:   2008-09-12 12:43:01 UTC+9
category: tex
tags: pdf
---

## TeX ドキュメントのコンパイル

### コンパイルコマンド

#### .tex -> .dvi

~~~sh
platex hoge.tex
~~~

#### .dvi -> .ps

~~~sh
dvipsk hoge.dvi
~~~

#### .dvi -> .pdf

~~~sh
dvipdfmx hoge.dvi
~~~

### Windows 環境と Unix 環境で作業する場合
文字コードで問題が出るので、EUC で統一する。Windows ではデフォルトが Shift_JIS なので、以下のようにコンパイルをする。 (Unix では普通にコンパイルする。)

~~~sh
platex -kanji=euc hoge.tex
~~~

