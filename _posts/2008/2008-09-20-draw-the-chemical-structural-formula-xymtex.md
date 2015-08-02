---
layout: post
title:  "XyMTeX で化学構造式を描く"
date:   2008-09-20 15:32:32
category: tex
---

## 化学構造式のスタイルパッケージ XyMTeX

化学構造式を描くためのパッケージです。コマンドに関しては、マニュアル（英語）を見たほうが詳しく書いてあります。他にはまとまったドキュメントが見つからないので、スタイルファイル (`*.sty`) を見て、定義されてるコマンド (`\def` の後ろ) を探す。

### 必要なパッケージ

- [epic.sty](http://www.mit.edu/afs/athena/contrib/tex-contrib/Chem2/xymtex/epic.sty) の追加
- パッケージ XyMTeX の導入

#### スタイルファイルのダウンロード

- Googleなど検索エンジンで検索
- [CTAN](http://www.ctan.org/search.html#byName) で探す（英語）

### スタイルファイルの導入

- epic.sty を XyMTeX パッケージの xymtex 内に入れる
- xymtex ディレクトリを以下のディレクトリ内に保存する

```
%INSTALL_DIR%\share\texmf\tex
```

%INSTALL_DIR% は TeX をインストールしたディレクトリに置き換える。


#### スタイルファイルの読み込み

コマンドプロンプト（端末）で以下のコマンドを実行する

```
mktexlsr
```

## XyMTeXの使い方

### スタイルファイルの呼び出し

プリアンブルに `\usepackage{xymtex}` を記述する。

#### 例：ベンゼン環を描く

```tex
\documentclass[12pt]{jarticle}
\usepackage{xymtex}
\begin{document}
\bzdrv{}
\end{document}
```

### コマンド一覧

Google Drive にファイルを共有しています。
[XyMTeX コマンド一覧](https://drive.google.com/folderview?id=0B2_vpZAj15VrUFZHZVZMNzBDdjg)

#### aliphat.sty

メタンとかエチレンとか描ける基本スタイルです。組み合わせ次第で、一般的なアルカン、アルケン、アルキンが描ける。

#### methylen.sty

重合体（ポリマー）に使えそうなスタイルです。

#### hetarom.sty

ベンゼン環にNとかOとかくっ付いてる奴（名前がわからない）

