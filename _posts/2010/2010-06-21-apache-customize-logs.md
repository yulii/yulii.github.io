---
layout: post
title:  "Apache ログの出力をカスタマイズする"
date:   2010-06-21 02:32:10 UTC+9
category: server
tags: apache
---

## ログ出力のカスタマイズ設定

### 1日毎にエラーログファイルを分割

ログローテートを指定する。

~~~
ErrorLog "| /usr/sbin/rotatelogs /var/log/apache2/error_log.%Y%m%d 86400"
~~~

### ログの出力形式を変更

ログファイルに書き出される情報をカスタマイズする。

~~~
LogFormat "%h %l %u %t \"%r\" %>s %b\ \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
~~~

### クローラーのアクセスログを分離

検索エンジンのクローラーがアクセスしたログを切り分けて出力する。

### クローラーの判別

User-Agent をもとにクローラーの判別条件を設定する。

~~~
# Crawler Access Log
SetEnvIf User-Agent "Googlebot" crawler no_log
SetEnvIf User-Agent "Googlebot-Image" crawler no_log
SetEnvIf User-Agent "InfoSeek Sidewinder" crawler no_log
SetEnvIf User-Agent "Slurp" crawler no_log
SetEnvIf User-Agent "mogimogi" crawler no_log
SetEnvIf User-Agent "indexpert" crawler no_log
SetEnvIf User-Agent "ZyBorg" crawler no_log
SetEnvIf User-Agent "nabot" crawler no_log
SetEnvIf User-Agent "Python-urllib" crawler no_log
SetEnvIf User-Agent "dloader" crawler no_log
SetEnvIf User-Agent "Openbot" crawler no_log
SetEnvIf User-Agent "ia_archiver" crawler no_log
SetEnvIf User-Agent "aruyo" crawler no_log
SetEnvIf User-Agent "Aruyo" crawler no_log
SetEnvIf User-Agent "fast" crawler no_log
SetEnvIf User-Agent "Scooter" crawler no_log
SetEnvIf User-Agent "tokiwa" crawler no_log
SetEnvIf User-Agent "moget" crawler no_log
SetEnvIf User-Agent "Girafabot" crawler no_log
SetEnvIf User-Agent "Ask Jeeves" crawler no_log
SetEnvIf User-Agent "Indy Library" crawler no_log
SetEnvIf User-Agent "NaverBot" crawler no_log
SetEnvIf User-Agent "msnbot" crawler no_log
SetEnvIf User-Agent "Baiduspider" crawler no_log
SetEnvIf User-Agent "sogou spider" crawler no_log
SetEnvIf User-Agent "yetibot" crawler no_log
SetEnvIf User-Agent "Yeti" crawler no_log
~~~

#### クローラーのアクセスログを1日毎に分割出力

~~~
CustomLog "| /usr/sbin/rotatelogs /var/log/apache2/crawler_log.%Y%m%d 86400" combined env=crawler
~~~

#### クローラー以外のアクセスログを1日毎に分割出力

~~~
CustomLog "| /usr/sbin/rotatelogs /var/log/apache2/access_log.%Y%m%d 86400" combined env=!no_log
~~~

