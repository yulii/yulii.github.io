---
layout: post
title:  "BIND9 動作不具合の対処方法 #Ubuntu Bug #289060"
date:   2009-09-28 00:43:03 UTC+9
tags: ubuntu
---

## BIND9 と AppArmor のプロファイル

以下のような Kernel エラーメッセージが出力され、起動できない場合の対処法です。

~~~
type=1503 audit(1253986105.197:304): operation="inode_permission" requested_mask="::r"
denied_mask="::r" fsuid=105 name="/proc/4111/net/if_inet6" pid=4112 profile="/usr/sbin/named"
~~~

### AppArmor の設定変更

AppArmor の設定ファイルを変更する。

#### /etc/apparmor.d/usr.sbin.named

以下の27行目を修正する。

~~~
27c27
< /proc/net/if_inet6 r,
---
> /proc/**/net/if_inet6 r,
~~~

修正後に AppArmor と BIND9 を再起動する。

~~~sh
sudo /etc/init.d/apparmor restart
sudo /etc/init.d/bind9 restart
~~~

### 参考URL

- [named bind9 apparmor profile error](https://bugs.launchpad.net/ubuntu/+source/bind9/+bug/289060)

