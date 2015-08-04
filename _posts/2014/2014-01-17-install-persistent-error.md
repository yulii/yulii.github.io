---
layout: post
title:  "Persistent インストールエラー対処 #Haskell"
date:   2014-01-17 13:03:32
category: haskell
---

## Haskell の Persistent インストール

`cabal` からインストールで依存ライブラリがなくてエラーした。

### Persistent::MySQL のインストール

```sh
# cabal install persistent-mysql-1.2.1
Resolving dependencies...
Configuring pcre-light-0.4...
cabal: Missing dependency on a foreign library:
* Missing C library: pcre
This problem can usually be solved by installing the system package that
provides this library (you may need the "-dev" version). If the library is
already installed but in a non-standard location then you can use the flags
--extra-include-dirs= and --extra-lib-dirs= to specify where it is.
Failed to install pcre-light-0.4
cabal: Error: some packages failed to install:
mysql-simple-0.2.2.4 depends on pcre-light-0.4 which failed to install.
pcre-light-0.4 failed during the configure step. The exception was:
ExitFailure 1
persistent-mysql-1.2.1 depends on pcre-light-0.4 which failed to install.
```

`pcre-light` が必要らしいので `cabal` からインストールを実行する。

```
# cabal install pcre-light-0.4
Resolving dependencies...
Configuring pcre-light-0.4...
cabal: Missing dependency on a foreign library:
* Missing C library: pcre
This problem can usually be solved by installing the system package that
provides this library (you may need the "-dev" version). If the library is
already installed but in a non-standard location then you can use the flags
--extra-include-dirs= and --extra-lib-dirs= to specify where it is.
Failed to install pcre-light-0.4
cabal: Error: some packages failed to install:
pcre-light-0.4 failed during the configure step. The exception was:
ExitFailure 1
```

足りない依存ライブラリでエラーが起きているので、下記のコマンドでライブラリをインストールする。

```
yum install pcre-devel
```

再度 `cabal install` を実行すればOK.

