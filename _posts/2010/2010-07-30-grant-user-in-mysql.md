---
layout: post
title:  "MySQL ユーザの設定方法"
date:   2010-07-30 00:30:01
category: database
tags: mysql
---

## MySQL ユーザの設定

DB の中にテーブルとして情報が保存されているので、レコード情報を追加変更することで設定できます。

### MySQL ユーザの確認

定義済みのユーザは、`mysql` データベースの `user` テーブルの情報を `SELECT` して確認できる。

```sql
SELECT user, host, password FROM mysql.user;
```

### ユーザ設定の変更

#### パスワードの設定

ユーザ名とホスト名を指定してパスワードを設定する。

```sql
SET PASSWORD FOR <user>@<host>=PASSWORD('<password>');
```

### ユーザの追加

#### 全権限を付与したユーザ作成

ユーザに対して権限を設定する `GRANT` 権限は付与されないです。

```sql
GRANT ALL ON *.* TO <user>@<host> IDENTIFIED BY '<password>';
FLUSH PRIVILEGES;
```

`GRANT` 権限も含めて付与する場合は `WITH GRANT OPTION` を指定する。

```sql
GRANT ALL ON *.* TO <user>@<host> IDENTIFIED BY '<password>' WITH GRANT OPTION;
```

#### 特定の権限を指定してユーザ作成

```sql
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON *.* TO <user>@<host> IDENTIFIED BY '<password>';
FLUSH PRIVILEGES;
```

