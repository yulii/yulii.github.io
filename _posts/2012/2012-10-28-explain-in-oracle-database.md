---
layout: post
title:  "SQL*Plusで「実行計画」を見える化"
date:   2012-10-28 01:40:24
category: database
tag: performance
---

## Oracle の実行計画 (EXPLAIN)

```sql
EXPLAIN PLAN FOR SELECT * FROM table;
```

## SQL チューニング

SQL チューニングするときに、それっぽいデータを出すためのおまじない

```
set linesize 1000;
set pagesize 50000;
col plan_plus_exp for a120;
set autotrace on;
set timing on;
set autotrace traceonly explain statistics;
```

おまじないを打ったあとに、普通にSQL (SELECT 文) を実行すると、INDEX の使われ方や JOIN の方式などクエリ実行時の詳細データが表示される。

EXPLAIN PLAN による実行計画の取得とは異なり DML の処理とフェッチ、データ転送処理も行なわれるため、大量の件数を取得する SQL の場合には注意！

実行計画の出力を止めるときは AUTOTRACE を OFF にする。

```
set autotrace off;
```

