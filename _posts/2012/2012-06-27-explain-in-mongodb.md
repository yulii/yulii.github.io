---
layout: post
title:  "MongoDB の実行計画 explain() を読んでみる"
date:   2012-06-27 16:48:23 UTC+9
category: engineering
tags: database mongodb performance
---

## explain() の使い方

```javascript
> db.users.find({ name: "yulii" }).explain()
{
     "cursor" : "BasicCursor",
     "nscanned" : 79349,
     "nscannedObjects" : 79349,
     "n" : 1,
     "scanAndOrder" : true,
     "millis" : 500,
     "nYields" : 0,
     "nChunkSkips" : 0,
     "isMultiKey" : false,
     "indexOnly" : false,
     "indexBounds" : {

     }
}
```

### explain() フィールドの意味

- cursor : ドキュメントの捜査方法 - インデックス利用時は “BtreeCursor” と表記
- nscanned : ドキュメントの読み取り数 - nscanned » n であればパフォーマンスが悪い
- n : クエリ実行結果のドキュメント数
- millis : クエリ実行時間 (ms)

## インデックスでパフォーマンス改善

```javascript
> db.users.getIndexes();
[
     {
          "v" : 1,
          "key" : {
               "_id" : 1
          },
          "ns" : "document.users",
          "name" : "_id_"
     }
]
> db.users.ensureIndex({ name: 1 }, { background: true });
> db.users.getIndexes();
[
     {
          "v" : 1,
          "key" : {
               "_id" : 1
          },
          "ns" : "document.users",
          "name" : "_id_"
     },
     {
          "v" : 1,
          "key" : {
               "name" : 1
          },
          "ns" : "document.users",
          "name" : "name_1",
          "background" : true
     }
]
```

### ensureIndex() の第1引数の意味

- `{ field: 1 }` : field の昇順インデックス
- `{ field: -1 }` : field の降順インデックス

第2引数で `{ background: true }` を指定すると、DBがロックされない。特別な理由がなければ付けておく。

```javascript
> db.users.find({ name: "yulii" }).explain()
{
     "cursor" : "BtreeCursor name_1",
     "nscanned" : 1,
     "nscannedObjects" : 1,
     "n" : 1,
     "scanAndOrder" : true,
     "millis" : 13,
     "nYields" : 0,
     "nChunkSkips" : 0,
     "isMultiKey" : false,
     "indexOnly" : false,
     "indexBounds" : {
          "name" : [
               [
                    "yulii",
                    "yulii"
               ]
          ]
     }
}
```

ちなみに、クエリ結果のデータが少ない場合 (4MB以下) ならインデックスなしで `sort()` が使えるが、 `limit()` と `sort()` を一緒に使うのが良いらしい。
