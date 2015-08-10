---
layout: post
title:  "TeX スタイルファイルの使い方と書き方"
date:   2009-04-03 06:29:43 UTC+9
category: tex
---

## TeX スタイルファイル

外部のスタイルファイルを利用する事で、文章表現を拡張できる。また、独自のマクロで新しいコマンドを定義してスタイルを拡張できる。

### スタイルファイルの使い方

プリアンブルの中で `\usepacage{}` で呼び出す。ファイル名の指定は拡張子 (`*.sty`) の省略が可能です。

#### 例: pifont.sty の呼び出し

```text
\documentclass[12pt]{jarticle}
% プリアンブル
\usepackage{pifont}
\begin{document}
 % 本文
\end{document}
```

## 独自のスタイルファイル作成

ファイル名を `*.sty` にして、TeX のコマンド等を記述する。

### スタイルファイル利用する便利なコマンド

- \usepacage : よく使うスタイルファイルを読み込む（あんまりたくさん書くと当然重くなる）
- \newcommand : 新しいコマンドを作成（既存のコマンド名と一緒だとエラー）
- \renewcommand : 既存のコマンドを書き換える

### スタイルファイルの保存場所

スタイルファイルを読み込むディレクトリがデフォルトで指定されてるので、それに合わせて保存する。

#### Linux (Ubuntu)

```
/usr/share/texmf/ptex/platex/
```

#### Windows

`%INSTALL_DIR%` はインストールしたディレクトリです。

```
%INSTALL_DIR%/share/texmf/tex/
```

サブディレクトリも検索してくれるので、配下に自分のスタイルファイルを保存するディレクトリを新しく作っても良いです。

#### スタイルファイルの登録

以下のコマンドを実行すると、保存したファイルをコンパイラが認識してくれます。

```
mktexlsr
```

### スタイルファイルの作成例

{% raw %}
```tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ファイルの詳細（省略可）
\def\j@urnalname{myset} \def\journalID{myset}
\def\versi@ndate{2005/12/21}
\def\versi@nno{ver1.00}
\def\copyrighth@lder{yulii}
\typeout{Package `\j@urnalname' (\versi@nno) <\versi@ndate>\space[\copyrighth@lder]}
\typeout{myset.sty ver1.00 (for LaTeX2e) 2005/12/21[yulii]}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% パッケージの呼び出し
\usepackage{fancybox,ascmac}
\usepackage{slashbox}
\usepackage{pifont}

% 新しいコマンドの作成
\newcommand{\txtc}[1]{\textcircled{\footnotesize #1}}
\newcommand{\txtb}[1]{\textgt{#1}}
\newcommand{\hs}[1]{\hspace{#1pt}}
\newcommand{\vs}[1]{\vspace{#1pt}}
\newcommand{\ms}[1]{\newcount\cnt\cnt=0\loop\ifnum#1>\cnt\;\advance\cnt by 1\repeat}

% マクロを利用した設定（あくまで例なので便利かどうかは別）
% 数字によってフォントの大きさを変える
\makeatletter
\def\txt{\@ifnextchar[{\@txt}{\@txt[]}}
\def\@txt[#1]#2{{%
  \@tfor\opti:=#1\do{%
    \ifcase\opti
    \tiny{}\or
    \scriptsize{}\or
    \footnotesize{}\or
    \normalsize{}\or
    \large{}\or
    \Large{}\or
    \LARGE{}\or
    \huge{}\or
    \Huge{}\fi
  #2}}}
\def\txtb{\@ifnextchar[{\@txtb}{\@txtb[]}}
\def\@txtb[#1]#2{{%
  \@tfor\opti:=#1\do{%
    \ifcase\opti
    \tiny{}\or
    \scriptsize{}\or
    \footnotesize{}\or
    \normalsize{}\or
    \large{}\or
    \Large{}\or
    \LARGE{}\or
    \huge{}\or
    \Huge{}\fi
    \textgt{#2}}}}
\makeatother

\endinput
```
{% endraw %}

