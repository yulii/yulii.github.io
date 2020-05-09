---
layout: post
title:  "Homebrew で使われていない formula を削除する"
date:   2020-05-09T15:16:18+0900
category: engineering
tags: shell
---

Homebrew でインストールした formula で使っていない不要なものを調査した。


## ほかの formula に依存していない formula を一覧化する

`brew uses` にかけると、何にも依存していないパッケージ (formula) を特定することができる。

```sh
brew list | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%20s is used by %2d formulae.\n" {}'
```

### xargs の並列実行バージョン（おすすめ）

実行に時間がかかるので、 `xargs -P3` など適宜並列プロセス数を指定すると良い。特にこだわりがなければ `expr $(sysctl -n hw.ncpu) - 1` で、CPUコア数から割り当てられるだけ指定する。

```sh
brew list | xargs -P`expr $(sysctl -n hw.ncpu) - 1` -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%20s is used by %2d formulae.\n" {}'
```

### コマンド実行結果

結果が0件の formula は削除できるので、不要なものを削除する。上記のコマンドは、依存がある削除できない formula も表示されるので、必要なら `| grep '0 formula'` する。

```sh
% brew list | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%20s is used by %2d formulae.\n" {}'
                 aom is used by  1 formulae.
               cairo is used by  3 formulae.
              docker is used by  0 formulae.
              ffmpeg is used by  0 formulae.
                flac is used by  4 formulae.
          fontconfig is used by  5 formulae.
            freetype is used by  6 formulae.
              frei0r is used by  1 formulae.
             fribidi is used by  2 formulae.
                gdbm is used by  6 formulae.


## 削除可能な formula のみを grep したバージョン
% brew list | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%20s is used by %2d formulae.\n" {}' | grep '0 formula'
              docker is used by  0 formulae.
              ffmpeg is used by  0 formulae.
                 git is used by  0 formulae.
             ilmbase is used by  0 formulae.
```


## 補足

### パッケージの依存関係

あるパッケージ (formula) が依存している formula を確認したければ `brew deps --tree` が便利です。

```sh
% brew deps --tree python  
python
├── gdbm
├── openssl@1.1
├── readline
├── sqlite
│   └── readline
└── xz
```

ほかのパッケージ (formula) から依存されていると削除できない。

```sh
% brew uninstall sqlite
Error: Refusing to uninstall /usr/local/Cellar/sqlite/3.30.1
because it is required by cairo, ffmpeg, glib, harfbuzz, libass and python, which are currently installed.
You can override this and force removal with:
  brew uninstall --ignore-dependencies sqlite
```

どこから依存されているかは `brew uses --installed` を確認する。

```sh
## どこからも依存されていない場合（削除可能）
% brew uses --installed ffmpeg


## ほかの formula から依存されている場合
% brew uses --installed readline
cairo                        ffmpeg                       glib                         harfbuzz                     libass                       python                       sqlite
```


## 参考記事

- [Homebrew の依存関係を表示する方法](https://yu8mada.com/2018/06/08/how-to-list-homebrew-dependencies/)
