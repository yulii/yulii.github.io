---
layout: post
title:  "SQL クエリのコーディング規約（スタイルガイド）"
date:   2016-03-27 19:14:28 UTC+9
category: database
tags: sql
---

SQLを読みやすくするためのインデントや記法に関するガイドです。個人的なルールかつ、厳格に決めていないので読みやすさを意識して調整したりします。各サンプルのクエリはMySQL で実行確認しています。

_コーディングスタイルの説明のため、クエリ自体にはあまり意味はないです。パフォーマンスの悪いクエリもありますがご了承ください。_

## SQL スタイルガイド

- 予約語/関数は大文字
    - `SELECT`, `INSERT`, `UPDATE`, `FROM`, `WHERE` など
- インデントはスペース2つ
- SELECT 句のカラム指定のカンマ `,` は先頭
- 条件の `AND` / `OR` は先頭
- セミコロン `;` は最終行
- `AS` は読みやすくするために適宜使う
    - AS 自体は省略して書いたりします

## SQL フォーマット

1行が1カラムに対する記述にまとまる様に意識して書いています。

### SELECT クエリのフォーマット

```sql
SELECT
  id
, name
FROM
  users
WHERE
  admin = 1
  AND password_digest IS NULL
  AND created_at >= '2016-01-01 00:00:00'
  AND created_at <  '2016-12-01 00:00:00'
ORDER BY
  id ASC
LIMIT
  0, 10
;
```

`LIMIT` の指定はカンマで改行を入れても良いですが、やや冗長な気がするのでまとめて1行で書いています。

### INSERT クエリのフォーマット

あまり書かないですが、たまにマスターデータやテスト用にデータを一括で入れる時には下記の様な形式で書いています。

```sql
INSERT INTO
  users (`name`, `email`, `admin`, `created_at`, `updated_at`)
VALUES
  ('John', 'john@example.com', 1, NOW(), NOW())
, ('Tom', 'tom@example.com', 0, NOW(), NOW())
, ('Robin', 'robin@example.com', 0, NOW(), NOW())
;
```

### UPDATE クエリのフォーマット

垂直方向にそろえるインデントが好きなので、 `=` など見やすくなりそうな位置で揃えます。

```sql
UPDATE
  microposts
SET
  content    = 'tweet'
, updated_at = NOW()
WHERE
  id = 5
;
```

## CASE 句など、1行1カラムにならない例外的なスタイル

改行のタイミングには厳格なルールはないですが、一行単位でまとまりになる様に適宜改行してます。あと、括弧 `()` だけでインデントはあんまりしないです。

```sql
SELECT
  (CASE u.admin
    WHEN 0 THEN 'member'
    WHEN 1 THEN 'admin'
    ELSE 'unknown'
  END)     AS user_type
, COUNT(*) AS user_count
FROM
  users u
GROUP BY
  u.admin
;
```

## テーブル結合 (JOIN)

`JOIN` は結合条件が比較的シンプルな場合が多いので、 `ON` 句を含めて1行に書く様にしています。複数のテーブルを結合するときには読みやすくなると思います。

```sql
SELECT
  m.user_id
, COUNT(*) post_count
FROM
  microposts m
  INNER JOIN users u ON u.id = m.user_id
WHERE
  u.admin = 0
GROUP BY
  m.user_id
;
```


## サブクエリ

ネストの深いSQL は読みづらいので、できるだけネストを浅くします。 `WITH` によってサブクエリ部分を外に出すことをお勧めします。ただ、MySQL には `WITH` が実装されていないので、仕方なくネストする場合は、スペース2つでインデントして書きます。

```sql
SELECT
  *
FROM
  users u
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      relationships r
    WHERE
      r.followed_id = u.id
  )
;
```

## `AS` の命名規約

厳格ではないですが、テーブル名の別名は元のテーブルがある程度分かる名前にします。サブクエリなどで一時的な集計テーブルが発生する場合は、何となく大文字で別名を付けています。名前が被って困る場合は、適当に上から順番に連番を振ります。

```sql
SELECT
  U.created_date
, SUM(U.user_count)  AS user_count
, SUM(U.post_count)  AS post_count
FROM
  -- 日次会員登録数
  (SELECT
    T1.created_date
  , COUNT(1)  AS user_count
  , 0         AS post_count
  FROM
    (SELECT
      u.id
    , CAST(u.created_at AS DATE) AS created_date
    FROM
      users u
    ) T1
  GROUP BY
    T1.created_date
  -- 日次投稿数
  UNION ALL SELECT
    T2.created_date
  , 0         AS user_count
  , COUNT(1)  AS post_count
  FROM
    (SELECT
      m.id
    , CAST(m.created_at AS DATE) AS created_date
    FROM
      microposts m
    ) T2
  GROUP BY
    T2.created_date
  ) U
GROUP BY
  U.created_date
;
```

さすがにルールに沿って書いても読みづらい。パフォーマンスのためにも、短くシンプルなSQL にした方が良いと思います。

## 参考：テーブル構成

サンプルコードのSQL は[Rails チュートリアル](http://railstutorial.jp/)のテーブル定義を使っています。

```sql
mysql> desc users;
+-----------------+--------------+------+-----+---------+----------------+
| Field           | Type         | Null | Key | Default | Extra          |
+-----------------+--------------+------+-----+---------+----------------+
| id              | int(11)      | NO   | PRI | NULL    | auto_increment |
| name            | varchar(255) | YES  |     | NULL    |                |
| email           | varchar(255) | YES  | UNI | NULL    |                |
| created_at      | datetime     | YES  |     | NULL    |                |
| updated_at      | datetime     | YES  |     | NULL    |                |
| password_digest | varchar(255) | YES  |     | NULL    |                |
| remember_token  | varchar(255) | YES  | MUL | NULL    |                |
| admin           | tinyint(1)   | YES  |     | NULL    |                |
+-----------------+--------------+------+-----+---------+----------------+

mysql> desc microposts;
+------------+--------------+------+-----+---------+----------------+
| Field      | Type         | Null | Key | Default | Extra          |
+------------+--------------+------+-----+---------+----------------+
| id         | int(11)      | NO   | PRI | NULL    | auto_increment |
| content    | varchar(255) | YES  |     | NULL    |                |
| user_id    | int(11)      | YES  | MUL | NULL    |                |
| created_at | datetime     | YES  |     | NULL    |                |
| updated_at | datetime     | YES  |     | NULL    |                |
+------------+--------------+------+-----+---------+----------------+

mysql> desc relationships;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| id          | int(11)  | NO   | PRI | NULL    | auto_increment |
| follower_id | int(11)  | YES  | MUL | NULL    |                |
| followed_id | int(11)  | YES  | MUL | NULL    |                |
| created_at  | datetime | YES  |     | NULL    |                |
| updated_at  | datetime | YES  |     | NULL    |                |
+-------------+----------+------+-----+---------+----------------+
```
