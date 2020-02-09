---
layout: post
title:  "Windows で Ruby のバージョン管理 (pik) を使う"
date:   2013-02-24T11:19:23+0900
category: engineering
---

## Windows 版 RVM

Ruby のバージョン管理 RVM のWindows 版 pik の使い方

### pik のインストール

[ダウンロード](https://github.com/vertiginous/pik/downloads)

.msi ファイルならポチポチするだけで入るのでカンタン。

### pik の使い方

ほぼ、RVM と同じ使い方だが、Ruby をインストールしようとしたらコケたのでメモ。

コマンドプロンプトから `pik install ruby` でインストールできる。

```
>pik install ruby

There was an error.
 Error: can't dup NilClass

  in: pathname.rb:205:in `dup'
  in: pathname.rb:205:in `initialize'
  in: pik/commands/add_command.rb:17:in `new'
  in: pik/commands/add_command.rb:17:in `add'
  in: pik/commands/add_command.rb:13:in `execute'
  in: pik_runner:27
```

見つからないと怒られたので、ダミーのRuby バージョンを設定ファイルに追加しておく

#### %USERPROFILE%.pik\config.yml

```
---
"000: ruby 0.0.0 (dummy ruby for pik)":
  :path: !ruby/object:Pathname
    path: %USERPROFILE%/.pik/dummy
--- {}

```
設定に追加されたことを list コマンドで確認する

```
>pik list
  000: ruby 0.0.0 (dummy ruby for pik)
```

`pik ls -r` でインストールできるパッケージリストがわかる。

改めて Ruby のインストールを実行する

```
>pik install ruby-1.9.2
ERROR: You need the 7zip utility to extract this file.
       Run 'pik package 7zip install'

>pik package 7zip install
INFO: Downloading:  http://downloads.sourceforge.net/sevenzip/7za920.zip
      to:  %USERPROFILE%\.pik\downloads\7za920.zip

7za920.zip: 100% |ooooooooooooooooooooooooooooo| 375.8KB/375.8KB Time: 00:00:00

>pik use ruby-1.9.2
```
