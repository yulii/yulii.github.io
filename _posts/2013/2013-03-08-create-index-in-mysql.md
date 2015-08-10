---
layout: post
title:  "MySQL でインデックスのチューニング入門"
date:   2013-03-08 06:43:05 UTC+9
category: database
tags: mysql performance
---

## MySQL でクエリのチューニング

正確なベンチマークではないので、実行時間は参考値として書いておきます。

### チューニングするテーブルの定義

```sql
mysql> DESC purchases;
+------------+----------+------+-----+---------+----------------+
| Field      | Type     | Null | Key | Default | Extra          |
+------------+----------+------+-----+---------+----------------+
| id         | int(11)  | NO   | PRI | NULL    | auto_increment |
| user_id    | int(11)  | YES  | MUL | NULL    |                |
| price      | int(11)  | YES  |     | 0       |                |
| created_at | datetime | YES  | MUL | NULL    |                |
| updated_at | datetime | YES  | MUL | NULL    |                |
| deleted_at | datetime | YES  | MUL | NULL    |                |
+------------+----------+------+-----+---------+----------------+
mysql> SELECT COUNT(1) FROM purchases;
+----------+
| count(1) |
+----------+
|   34,321 |
+----------+
```

チューニングするSQLは以下の通り。月次集計の分析用に書いた奴なので、ちょっとアプリケーション内で発行するクエリと比べると、実運用っぽくないが・・・。

```sql
SELECT
    T.CREATED_YM CREATED_YM
    ,COUNT(T.USER_ID) PU_COUNT
FROM
    (SELECT
        P.USER_ID USER_ID
        ,DATE_FORMAT(MIN(P.CREATED_AT), '%Y/%m/01') CREATED_YM
    FROM
        PURCHASES P
    GROUP BY
        P.USER_ID
    ) T
GROUP BY
    T.CREATED_YM
ORDER BY
    T.CREATED_YM
;
```

レコードが34,000件程度なのでそんなに数がないが、実行時間は 1 min 22.77 sec くらい。

### チューニング前の実行計画 (EXPLAIN)

`EXPLAIN` を頭に付けて、実行計画を確認すると・・・

```sql
+----+-------------+------------+-------+---------------+---------+---------+------+-------+---------------------------------+
| id | select_type | table      | type  | possible_keys | key     | key_len | ref  | rows  | Extra                           |
+----+-------------+------------+-------+---------------+---------+---------+------+-------+---------------------------------+
|  1 | PRIMARY     | <derived2> | ALL   | NULL          | NULL    | NULL    | NULL |  9402 | Using temporary; Using filesort |
|  2 | DERIVED     | P          | index | NULL          | user_id | 5       | NULL | 31343 |                                 |
+----+-------------+------------+-------+---------------+---------+---------+------+-------+---------------------------------+
```

user_id のインデックスでとりあえず頑張ってくれている模様。

### "適切な" インデックスを作成してみる

現状を `SHOW INDEX` で確認すると・・・

```sql
mysql> SHOW INDEX FROM purchases;
+-----------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table     | Non_unique | Key_name   | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-----------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| purchases |          0 | PRIMARY    |            1 | id          | A         |       32871 |     NULL | NULL   |      | BTREE      |         |               |
| purchases |          1 | user_id    |            1 | user_id     | A         |       32871 |     NULL | NULL   | YES  | BTREE      |         |               |
| purchases |          1 | created_at |            1 | created_at  | A         |       32871 |     NULL | NULL   | YES  | BTREE      |         |               |
| purchases |          1 | updated_at |            1 | updated_at  | A         |       32871 |     NULL | NULL   | YES  | BTREE      |         |               |
+-----------+------------+------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
```

SQL で使用しているカラムのuser_id, created_at それぞれにインデックスがあるが、1つしか使えないのでうまく最適化されない。複合インデックスを作成すると解消できる。ただし、where / group by 指定のカラムをまとめて指定するかつ順番にも注意が必要。Covering Index で調べると良い事あるかも。

```sql
mysql> ALTER TABLE  purchases ADD INDEX created_at_group_by_user_id(id, created_at);
mysql> SHOW INDEX FROM purchases;
+-----------+------------+-----------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table     | Non_unique | Key_name                    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-----------+------------+-----------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| purchases |          0 | PRIMARY                     |            1 | id          | A         |       32871 |     NULL | NULL   |      | BTREE      |         |               |
| purchases |          1 | user_id                     |            1 | user_id     | A         |       32871 |     NULL | NULL   | YES  | BTREE      |         |               |
| purchases |          1 | created_at                  |            1 | created_at  | A         |       32871 |     NULL | NULL   | YES  | BTREE      |         |               |
| purchases |          1 | updated_at                  |            1 | updated_at  | A         |       32871 |     NULL | NULL   | YES  | BTREE      |         |               |
| purchases |          1 | created_at_group_by_user_id |            1 | user_id     | A         |         200 |     NULL | NULL   | YES  | BTREE      |         |               |
| purchases |          1 | created_at_group_by_user_id |            2 | created_at  | A         |         200 |     NULL | NULL   | YES  | BTREE      |         |               |
+-----------+------------+-----------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
```

もう一度、さっきのSQL を実行すると、0.26 sec になった。ちなみに、実行計画を確認すると・・・

```sql
+----+-------------+------------+-------+---------------+-----------------------------+---------+------+------+---------------------------------+
| id | select_type | table      | type  | possible_keys | key                         | key_len | ref  | rows | Extra                           |
+----+-------------+------------+-------+---------------+-----------------------------+---------+------+------+---------------------------------+
|  1 | PRIMARY     | <derived2> | ALL   | NULL          | NULL                        | NULL    | NULL | 9402 | Using temporary; Using filesort |
|  2 | DERIVED     | E          | range | NULL          | created_at_group_by_user_id | 14      | NULL |  201 | Using index for group-by        |
+----+-------------+------------+-------+---------------+-----------------------------+---------+------+------+---------------------------------+
```

参考例が分析用でそもそもSQL 自体にちょっとよろしくない部分があるので、`EXPLAIN` を見ながらどんなインデックスを設定するか考える参考になれば・・・。

