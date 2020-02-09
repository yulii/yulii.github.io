---
layout: post
title:  "プロセス監視とデーモン化ツールまとめ"
date:   2014-01-17T15:15:23+0900
category: engineering
tags: server supervision
---

## プロセス監視ツール

プロセスの死活監視やデーモン化が出来るツールを調べてみた。全部は試せていないが、

- daemontools
- [upstart](http://upstart.ubuntu.com/)
- runit
- [Monit](http://mmonit.com/monit/)
- [Supervisor](http://supervisord.org/)
- [Angel](https://github.com/MichaelXavier/Angel)

などが使える。PID ファイルを利用するもの、プロセス自体を fork 起動して監視するものがある。

- カッチリ設定するなら `upstart`
- `/etc/init.d/*` の起動スクリプトもしくは PID ファイルがあるなら `Monit`
- 起動スクリプトや PID ファイルがないなら `Supervisor`

### Monit

`/etc/init.d/*` の起動スクリプトがあるサービスなら簡単に設定できる。

- PID ファイルがあれば簡単にプロセス監視できる
- Monit 5.2 以降なら `matching` で PID ファイルがない場合も対応可能
- 秒単位で監視が可能（間隔分のダウンタイムが発生する）
- cron で `monit monitor all` を定期的に実行した方が良い

#### SSH の監視設定例

PID ファイルのパスと起動・停止方法を設定する。

```
check process sshd with pidfile /var/run/sshd.pid
start program = "/etc/init.d/sshd start" with timeout 3 seconds
stop  program = "/etc/init.d/sshd stop"
```

### Supervisor

独自スクリプトや init スクリプトがないプログラムをデーモン化できる。Python 製なので、`easy_install` からインストールできる。アラート設定（イベント）は [superlance](http://superlance.readthedocs.org/en/latest/index.html) のプラグインで対応可能です（拡張性があまりよくなかったので、メール文面を変えたりしたいなら自作するしかなさそう）。

- 設定ファイルを追加するだけで、デーモン化＆プロセス監視できる
- 子プロセスとして動作するので、プロセスの復帰がほぼノータイム
- 管理しているプロセスの起動順序（優先度）を設定できる
- すべてのプロセスが子プロセスとして動くので、本体が落ちると全部落ちる

#### SSH の監視設定例

起動コマンドや起動ユーザを設定する。デーモン起動ではなく、フォアグラウンドで通常起動するコマンドを設定すること。

```
[program:sshd]
command=/usr/sbin/sshd -D
process_name=%(program_name)s
priority=955
autostart=true
autorestart=true
user=root
directory=/tmp
```

リモート経由で設定する時は、一度 SSHD を停止して Supervisor 経由で立ち上げ直す必要があるので、サーバーから閉め出されないように注意。

### Angel

Haskell 製のプロセスのデーモン化ツール。`cabal` からインストールできる。使い方は [「Yesod アプリケーションの本番環境デプロイ」](http://yulii.net/entries/10) などを参照してください。

- 設定ファイルを追加するだけで、デーモン化＆プロセス監視できる
- 子プロセスとして動作するので、プロセスの復帰がほぼノータイム
- すべてのプロセスが子プロセスとして動くので、本体が落ちると全部落ちる

### upstart

実際に設定していないので調べたメモ。

- init スクリプトの代わりとなる設定追加が必要
- イベントベースで設定が出来る（プロセス間の依存関係を設定できる）
- SysVinit と比べてサーバーの起動時間が短縮できる

CentOS 6 で、SysVinit から upstart へ以降など起こっているらしい。

```sh
$ cat /etc/inittab
# inittab is only used by upstart for the default runlevel.
#
# ADDING OTHER CONFIGURATION HERE WILL HAVE NO EFFECT ON YOUR SYSTEM.
#
# System initialization is started by /etc/init/rcS.conf
#
# Individual runlevels are started by /etc/init/rc.conf
#
# Ctrl-Alt-Delete is handled by /etc/init/control-alt-delete.conf
#
# Terminal gettys are handled by /etc/init/tty.conf and /etc/init/serial.conf,
# with configuration in /etc/sysconfig/init.
#
# For information on how to write upstart event handlers, or how
# upstart works, see init(5), init(8), and initctl(8).
#
# Default runlevel. The runlevels used are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused
#   5 - X11
#   6 - reboot (Do NOT set initdefault to this)
#
id:3:initdefault:
```

### 外部サービスの監視ツール UptimeRobot

Web サービスの監視 HTTP (S) や `ping`, ポートの監視が出来る。メールやTwitter へのアラート設定ができる。プロセスの自動復帰はできないけど、アラートだけ飛ばすなら簡単に使える。

Uptime Robot [http://uptimerobot.com/](http://uptimerobot.com/)
