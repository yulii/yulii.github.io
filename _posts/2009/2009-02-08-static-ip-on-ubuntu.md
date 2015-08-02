---
layout: post
title:  "Ubuntu の固定IPアドレス設定方法"
date:   2009-02-08 05:45:03
category: unix
tags: ubuntu
---

## 固定IP アドレスの設定

時間が経つと DHCP で IP が変わってしまう問題の対処法 (Ubuntu 8.04 - 8.10)

### NetworkManager の削除

NetworkManager のバグ等が原因みたいなので削除する。

```sh
sudo update-rc.d -f NetworkManager remove
```

### 固定IP の設定

#### /etc/network/interfaces

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.168.0.1
netmask 255.255.255.0
network 192.168.0.0
broadcast 192.168.0.255
gateway 192.168.0.254
```

#### /etc/resolv.conf

resolv.conf の所有グループを root に変更する。

```sh
sudo chgrp root /etc/resolv.conf
```

