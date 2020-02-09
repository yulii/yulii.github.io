---
layout: post
title:  "パッケージ管理ツール Homebrew のインストール"
date:   2013-12-07T11:00:13+0900
---

## Homebrew のインストール手順

Xcode をアップデートするついでに Homebrew を再度入れ直した。

### MacPorts の削除

管理者権限でファイル削除するのでコピペ注意!!

```sh
sudo port -fp uninstall installed
sudo rm -rf \
    /opt/local \
    /Applications/DarwinPorts \
    /Applications/MacPorts \
    /Library/LaunchDaemons/org.macports.* \
    /Library/Receipts/DarwinPorts*.pkg \
    /Library/Receipts/MacPorts*.pkg \
    /Library/StartupItems/DarwinPortsStartup \
    /Library/Tcl/darwinports1.0 \
    /Library/Tcl/macports1.0 \
    ~/.macports
```

### Homebrew のインストール

```sh
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
```

### Homebrew を利用する準備

環境チェックを行い問題が無いか確認する。

```sh
brew doctor
```

#### osx-gcc-installer の警告

```
Warning: You seem to have osx-gcc-installer installed.
Homebrew doesn't support osx-gcc-installer. It causes many builds to fail and
is an unlicensed distribution of really old Xcode files.
Please install the CLT or Xcode 4.6.3.
```

Xcode を起動して、[Xcode] > [Preferences] メニューを開き、[Downloads] > [Components] 画面から「Command Line Tools」をインストールすればOK.

#### プログラムの重複

```
Warning: /usr/bin occurs before /usr/local/bin
This means that system-provided programs will be used instead of those
provided by Homebrew. The following tools exist at both paths:

    git
    git-cvsserver
    git-receive-pack
    git-shell
    git-upload-archive
    git-upload-pack

Consider setting your PATH so that /usr/local/bin
occurs before /usr/bin. Here is a one-liner:
    echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
```

何故か、古いバージョンの git が `/usr/bin` にインストールされていたので削除した。

```sh
sudo rm -f /usr/bin/git*
```

メッセージの指示通り、環境変数 `PATH` で /usr/local/bin が優先されるように変更してもOK.

#### requirement エラー

```
Error: Failed to import: composer-requirement
No available formula for composer-requirement
Error: Failed to import: homebrew-php-requirement
No available formula for homebrew-php-requirement
Error: Failed to import: phar-building-requirement
No available formula for phar-building-requirement
Error: Failed to import: phar-requirement
No available formula for phar-requirement
Error: Failed to import: php-meta-requirement
No available formula for php-meta-requirement
```

Formula に関係したバグっぽいが、以下のおまじないで消える。

```sh
find $(brew --prefix)/Library/Formula -type l -name "*requirement.rb" -delete
```

これで、`brew update` して使える。

### Homebrew の環境確認

`brew --config` でHomebrew の環境を確認できる。

```
HOMEBREW_VERSION: 0.9.5
ORIGIN: https://github.com/mxcl/homebrew
HEAD: 3d7f04fdd84b5cfc98d6ae283d0abe7fa9bc4e28
HOMEBREW_PREFIX: /usr/local
HOMEBREW_CELLAR: /usr/local/Cellar
CPU: quad-core 64-bit sandybridge
OS X: 10.7.5-x86_64
Xcode: 4.6.3
CLT: 1.0.0.9000000000.1.1249367152
GCC-4.2: build 5666
LLVM-GCC: build 2336
Clang: 4.2 build 425
X11: 2.6.5 => /usr/X11
System Ruby: 1.8.7-358
Perl: /usr/bin/perl
Python: /usr/bin/python
Ruby: /Users/yulii/.rvm/rubies/ruby-2.0.0-p247/bin/ruby
```

参考まで。

