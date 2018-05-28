---
layout: post
title:  "Re:dash に登録実行されているクエリを整理する"
date:   2018-05-28 23:57:35 UTC+9
tag: sql
---

Re:dash を運用していると、使えば使うほどクエリが増える。不要なクエリが定期実行されてたり、やんちゃなクエリでRe:dash サーバーが落ちることもしばしば。

Re:dash をインストールした時に作成されるデータベースにクエリの実行結果などの情報が保存されます。このデータベースをみれば、どのクエリを見直したり、削除すれば良いかわかります。


## データソースを登録する

![Re:dash data source](/img/posts/2018/2018-05-28-redash-data-source.png)

PostgreSQL をデータソースとして登録して利用します。DBへの接続ユーザーはRe:dash のインストール方法に合わせて指定します。


## 整理が必要そうなクエリを見つける


### 使われていないクエリ

定期実行されいている場合は `events` に実行ログが残らないらしい。定期実行の設定がないクエリで実行回数が少ないクエリを抽出する。

```sql
select
  q.name
, coalesce(E.exec_count, 0)  exec_count
, 'https://redash.io/queries/' || q.id || '/source'  as url
from
  queries q
  left join (
    select
      e.object_id
    , count(e.id) exec_count
    from
      events e
    where
      e.action = 'execute'
      and e.created_at >= CURRENT_DATE - integer '180'  -- 過去6ヶ月以内に実行されたクエリを対象にする
    group by
      e.object_id
  ) E on cast(E.object_id as int) = q.id
where
  q.schedule is null
order by
  exec_count asc
, q.id asc
;
```


### 定期実行されているクエリ

定期実行されているクエリの時間帯に偏りがないか。 `schedule_failures` を見てエラーしているクエリが定期実行されていないか。


```sql
select
  q.name
, q.schedule
, q.schedule_failures
, 'https://redash.io/queries/' || q.id || '/source'  as url
from
  queries q
where
  q.schedule <> ''
order by
  q.schedule_failures desc
;
```


### 実行時間の長いクエリ

実行時間の長いクエリが複数同時に流れるとキューが詰まる。

```sql
with QH as (
select
  query_hash
, count(query_hash)  as run_count
, min(runtime)       as min_runtime
, avg(runtime)       as avg_runtime
, max(runtime)       as max_runtime
from
  query_results
where
  retrieved_at >= CURRENT_DATE - integer '7'  -- 過去1週間に実行されたクエリを対象にする
group by
  query_hash
)

select
  QH.run_count
, QH.min_runtime
, QH.avg_runtime
, QH.max_runtime
, q.name
, 'https://redash.io/queries/' || q.id || '/source'  as url
, qr.query
from
  QH
  left join queries as q        on q.query_hash  = QH.query_hash
  left join query_results as qr on qr.query_hash = QH.query_hash
order by
  avg_runtime desc
;
```

### 実行結果のデータ量が多いクエリ

データを取り出しすぎると、一発でサーバーが死ぬ場合があるので要注意。できれば、サーバーが落ちる前の防止策が欲しい。

クエリ実行の結果のデータ量の上限指定して、強制的にクエリ実行が止まるとか...

```sql
with QH as (
select
  query_hash
, count(query_hash)  as run_count
, max(json_array_length(data::json->'rows')) as row_count
, max(octet_length(data))  as data_length
, avg(runtime)       as runtime
from
  query_results
where
  retrieved_at >= CURRENT_DATE - integer '7'  -- 過去1週間に実行されたクエリを対象にする
group by
  query_hash
)

select
  QH.run_count
, QH.row_count
, QH.data_length
, QH.runtime
, q.name
, 'https://redash.io/queries/' || q.id || '/source'  as url
from
  queries as q
  inner join QH on q.query_hash = QH.query_hash
order by
  row_count desc
;
```

JSON データを加工しているので、このクエリ自身がやや重たい... :fearful:
