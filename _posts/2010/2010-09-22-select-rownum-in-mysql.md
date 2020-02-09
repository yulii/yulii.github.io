---
layout: post
title:  "MySQL で問い合わせ結果の行番号 ROWNUM を取得する"
date:   2010-09-22T14:10:09+0900
category: engineering
tags: database mysql sql
---

## MySQL で擬似的な ROWNUM

Oracle Database にある ROWNUM を MySQL でやってみた。Oracle Database は触った事がないので、実際のところは知らないので妄想ベースです。

### ROWNUM を取得するSQL クエリ

ローカル変数 `@i` を使って問い合わせ結果に1番から始まる連番を振る。変数の初期化は `FROM` 句の中で定義する。

```sql
SELECT
  @i:=@i+1 AS ROWNUM
, <col>
FROM
  (SELECT @i:=0) AS INDEX_NUM
, <table>
;
```

取得するテーブル `<table>` やカラム `<col>` は適宜指定してください。

### ページングの対応

ページングで `LIMIT` と `OFFSET` を指定する場合のクエリは `@i` にあらかじめ `OFFSET` を設定しておく。

```sql
SELECT
  @i:=@i+1 AS ROWNUM
, <col>
FROM
  (SELECT @i:=<offset>) AS INDEX_NUM
, <table>
LIMIT
  <limit>
OFFSET
  <offset>
;
```

取得するテーブル `<table>` やカラム `<col>` は適宜指定してください。また、ページングに合わせて、取り出す件数 `<limit>` と開始位置 `<offset>` を適宜指定してください。
