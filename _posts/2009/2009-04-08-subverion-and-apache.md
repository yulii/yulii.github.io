---
layout: post
title:  "Subversion とApache の連携設定"
date:   2009-04-08 02:32:54 UTC+9
category: server
tags: apache subversion
---

## Apache との連携

Web ブラウザ上 (80番ポート) からリポジトリにアクセスする必要がなければ設定不要です。

### Subversion のインストール

必要なライブラリと合わせてインストールする。

~~~sh
sudo apt-get install subversion subversion-tools libapache2-svn
~~~

### Apache の設定

ブラウザからレポジトリへアクセスができる様に設定を追加する。必要があればユーザ認証を設定をします。

~~~sh
$ sudo vi /etc/apache2/mods-enabled/dav_svn.conf

<Location /svn>
  DAV svn
  SVNParentPath /var/www/svn

  #ユーザ認証
  AuthType Basic
  AuthName "Subversion Repository"
  AuthUserFile /etc/apache2/dav_svn.passwd
  Require valid-user

  #ユーザ制限
  # AuthzSVNAccessFile /etc/apache2/dav_svn.authz
</Location>
~~~

設定後はApache を再起動する。

~~~sh
sudo /etc/init.d/apache2 restart
~~~

#### ユーザ設定ファイルの作成

`htpasswd` でベーシック認証用のユーザ設定ファイルを作成する。

~~~sh
$ sudo htpasswd -c /etc/apache2/dav_svn.passwd username
New password:
Re-type new password:
Adding password for user secret
~~~

