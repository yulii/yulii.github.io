---
layout: post
title:  "MySQL でテーブルやカラムの情報を確認する方法まとめ"
date:   2015-09-01T23:42:42+0900
category: engineering
tags: database mysql sql
---

MySQL で作成済みのテーブルやカラムの定義を調べる方法をまとめました。知っておくといろいろ捗るかも。

## DESC

```sql
DESC `users`;
SHOW COLUMNS FROM `users`;
```

出力結果は以下の通り

```sql
+-------+--------------+------+-----+---------+-------+
| Field | Type         | Null | Key | Default | Extra |
+-------+--------------+------+-----+---------+-------+
| id    | int(11)      | NO   | PRI | 0       |       |
| name  | varchar(64)  | NO   | UNI | NULL    |       |
| age   | int(11)      | NO   |     | NULL    |       |
| photo | varchar(255) | YES  |     | NULL    |       |
+-------+--------------+------+-----+---------+-------+
```

## SHOW CREATE TABLE

`CREATE TABLE` で定義されたクエリ情報が確認出来る。

```sql
SHOW CREATE TABLE `users`\G;
```

出力結果は以下の通り

```sql
*************************** 1. row ***************************
       Table: users
Create Table: CREATE TABLE `users` (
  `id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(64) NOT NULL,
  `age` int(11) NOT NULL,
  `photo` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
```

## INFORMATION_SCHEMA

`INFORMATION_SCHEMA` データベース内にスキーマの定義情報が保存されている。
カラムの情報が欲しい場合は `COLUMNS` テーブルを参照すれば確認出来る。

```sql
SELECT
  TABLE_NAME
, COLUMN_NAME
, COLUMN_TYPE
, IS_NULLABLE
, COLUMN_KEY
, COLUMN_DEFAULT
, EXTRA
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_SCHEMA = 'database_name'
;
```

出力結果は以下の通り

```sql
+------------+-------------+--------------+-------------+------------+----------------+-------+
| TABLE_NAME | COLUMN_NAME | COLUMN_TYPE  | IS_NULLABLE | COLUMN_KEY | COLUMN_DEFAULT | EXTRA |
+------------+-------------+--------------+-------------+------------+----------------+-------+
| users      | id          | int(11)      | NO          | PRI        | 0              |       |
| users      | name        | varchar(64)  | NO          | UNI        | NULL           |       |
| users      | age         | int(11)      | NO          |            | NULL           |       |
| users      | photo       | varchar(255) | YES         |            | NULL           |       |
+------------+-------------+--------------+-------------+------------+----------------+-------+
```

`WHERE` 句で絞り込み出来るので、NOT NULL 制約のカラムを探したり、特定のデータ型のカラムを探せる。
当然 `LIKE` クエリも使えるので、命名規則に沿ったカラムを探すのも出来る。
ER 図などのドキュメントが無いときに役立つかも。

### テーブル単位のデータサイズを確認する

今回の本筋とは異なるが、 `INFORMATION_SCHEMA` データベースには他にも便利な情報が入っています。
例えば、 `TABLES` テーブルを参照すると使用中のデータ容量やインデックス容量を調べることが出来る。

```sql
SELECT
  TABLE_NAME
, ENGINE
, TABLE_ROWS                                                      -- レコード数
, AVG_ROW_LENGTH                                                  -- 平均レコード容量
, FLOOR((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS SIZE       -- 合計容量
, FLOOR((DATA_LENGTH) / 1024 / 1024)                AS DATA_SIZE  -- データ容量
, FLOOR((INDEX_LENGTH) / 1024 / 1024)               AS INDEX_SIZE -- インデックス容量
FROM
  INFORMATION_SCHEMA.TABLES
WHERE
  TABLE_SCHEMA = DATABASE()
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH) DESC
;
```

出力結果は以下の通り

```sql
+------------+--------+------------+----------------+------+-----------+------------+
| TABLE_NAME | ENGINE | TABLE_ROWS | AVG_ROW_LENGTH | SIZE | DATA_SIZE | INDEX_SIZE |
+------------+--------+------------+----------------+------+-----------+------------+
| users      | InnoDB |     101471 |            150 |   14 |        14 |          0 |
| items      | InnoDB |      25319 |            559 |   13 |        13 |          0 |
| orders     | InnoDB |      71579 |            139 |   11 |         9 |          1 |
+------------+--------+------------+----------------+------+-----------+------------+
```

### 複数データベースをまとめて調べるときは注意

本番環境 (production) で何度も問い合わせるようなクエリではないものの、 `INFORMATION_SCHEMA` クエリのパフォーマンスについては注意が必要です。

> #### パフォーマンスに関する考慮事項
> 複数のデータベースの情報を検索する INFORMATION_SCHEMA クエリーは、長時間かかり、パフォーマンスに影響を及ぼす可能性があります。
> クエリーの効率を確認するには、EXPLAIN を使用できます。EXPLAIN 出力を使用した INFORMATION_SCHEMA クエリーの調整に関する詳細は、
>「[INFORMATION_SCHEMA クエリーの最適化](http://dev.mysql.com/doc/refman/5.6/ja/information-schema-optimization.html)」を参照してください。
>
> _cf. [第21章 INFORMATION_SCHEMA テーブル](http://dev.mysql.com/doc/refman/5.6/ja/information-schema.html)_
