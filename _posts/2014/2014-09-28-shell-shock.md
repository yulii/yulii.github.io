---
layout: post
title:  "Bash 脆弱性の対応 #ShellShock (Mac OS X)"
date:   2014-09-28 14:47:54 UTC+9
image:  2014-09-28-kv
category: unix
tags: shell security
---

Bash に含まれる深刻なバグ (通称: ShellShock) の対応方法について

## 脆弱性の報告

環境変数に仕込まれたコードを実行してしまう脆弱性が報告される。ややこしいことに2件立て続けに報告されているので注意。

- [CVE-2014-6271 Learn more at National Vulnerability Database (NVD)](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-6271)
- [CVE-2014-7169 Learn more at National Vulnerability Database (NVD)](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-7169)

CVE-2014-6271 の対策パッチは修正不十分である指摘があり、CVE-2014-7169 を含めた対応が必要です。

### 脆弱性のチェック

#### CVE-2014-6271 のチェック

下記のコマンドで確認できる

```
env x='() { :;}; echo vulnerable' bash -c "echo this is a test”
```

##### 脆弱性なし

```
$ env x='() { :;}; echo vulnerable' bash -c "echo this is a test"
bash: warning: x: ignoring function definition attempt
bash: error importing function definition for `x'
hello
```

##### 脆弱性あり

```
$ env x='() { :;}; echo vulnerable' bash -c "echo this is a test"
 vulnerable
 this is a test
```

見たまんま「脆弱性あるよ！」って返って来たらマズい。

#### CVE-2014-7169 のチェック

下記のコマンドで確認できる

```
cd /tmp; rm -f /tmp/echo; env 'x=() { (a)=>\' bash -c "echo date"; cat /tmp/echo
```

##### 脆弱性なし

```
$ cd /tmp; rm -f /tmp/echo; env 'x=() { (a)=>\' bash -c "echo date"; cat /tmp/echo
date
cat: /tmp/echo: No such file or directory
```

##### 脆弱性あり

```
$ cd /tmp; rm -f /tmp/echo; env 'x=() { (a)=>\' bash -c "echo date"; cat /tmp/echo
bash: x: line 1: syntax error near unexpected token `='
bash: x: line 1: `'
bash: error importing function definition for `x'
Fri Sep 26 11:49:58 GMT 2014
```

若干エラーメッセージが混じるが、脆弱性がある場合には `date` コマンドが実行されて日付が表示される

## Homebrew でアップグレード

Homebrew 経由で最新版のbash をインストールできる。

```
brew update
brew upgrade bash
```

`/bin/bash` は変更されないので、インストール先のファイル `/usr/local/bin/bash` を適宜コピーする。

```
sudo cp /usr/local/bin/bash /bin/bash
```

### bash バージョンを確認

#### 古いバージョン

```
$ bash --version
GNU bash, version 3.2.51(1)-release (x86_64-apple-darwin13)
Copyright (C) 2007 Free Software Foundation, Inc.

```

### 新しいバージョン

```
$ bash --version
GNU bash, version 4.3.26(1)-release (x86_64-apple-darwin13.4.0)
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

```

ちなみに、`/bin/sh` も中身が bash かもしれないので `sh --version` で確認して、必要があればファイルを入れ替えた方が良い。

## 参考情報

- [GNU bash の脆弱性に関する注意喚起](https://www.jpcert.or.jp/at/2014/at140037.html)
- [bashの脆弱性(CVE-2014-6271) #ShellShock の関連リンクをまとめてみた](http://d.hatena.ne.jp/Kango/20140925/1411612246)
- [閲覧でウイルス感染も「ｂａｓｈ」に重大欠陥](http://www3.nhk.or.jp/news/html/20140927/k10014922101000.html)

