---
layout: post
title:  "MongoDB のクエリ $in と $or について調べてみた"
date:   2012-08-14 01:44:42 UTC+9
category: database
tags: mongodb
---

## MongoDB クエリ最適化

条件オペレータ `$in` について試してみた。

~~~sh
> db.animals.find({}).count();
100248
> db.animals.getIndexes();
[
     {
          "v" : 1,
          "key" : {
               "_id" : 1
          },
          "ns" : "document.animals",
          "name" : "_id_"
     },
     {
          "v" : 1,
          "key" : {
               "type" : 1
          },
          "ns" : "document.animals",
          "name" : "type_1",
          "background" : true
     }
]
~~~

インデックスを張った "type" フィールドに対して `$in` オペレーターで絞り込みする。

~~~sh
> db.animals.find({ type: { $in: ["dog", "cat"] } }).explain();
{
     "cursor" : "BtreeCursor type_1 multi",
     "nscanned" : 3470,
     "nscannedObjects" : 3469,
     "n" : 3144,
     "millis" : 109,
     "nYields" : 0,
     "nChunkSkips" : 0,
     "isMultiKey" : false,
     "indexOnly" : false,
     "indexBounds" : {
          "type" : [
               [
                    "dog",
                    "dog"
               ],
               [
                    "cat",
                    "cat"
               ]
          ]
     }
}
~~~

配列指定の条件となるがインデックスが効くのでそこそこ速い。ためしに、否定形の `$nin` オペレーターで絞り込みしてみる。

~~~sh
> db.animals.find({ type: { $nin: ["bird", "monkey"] } }).explain();
{
     "cursor" : "BasicCursor",
     "nscanned" : 100248,
     "nscannedObjects" : 100248,
     "n" : 3145,
     "millis" : 621,
     "nYields" : 0,
     "nChunkSkips" : 0,
     "isMultiKey" : false,
     "indexOnly" : false,
     "indexBounds" : {

     }
}
~~~

インデックスが効かず、全ドキュメントを走査して残念な感じになった。Oracle, MySQL などのRDB でも INDEX (B-Tree) カラムに対してNOT 演算が入るとインデックスが使用されない。

ためしついでに、`$in` 条件と同等の `$or` 条件で検索してみると・・・

~~~sh
> db.animals.find({ $or: [{ type: "dog" }, { type: "cat" }] }).explain();
{
     "clauses" : [
          {
               "cursor" : "BtreeCursor type_1",
               "nscanned" : 8,
               "nscannedObjects" : 8,
               "n" : 7,
               "millis" : 0,
               "nYields" : 0,
               "nChunkSkips" : 0,
               "isMultiKey" : false,
               "indexOnly" : false,
               "indexBounds" : {
                    "role" : [
                         [
                              "dog",
                              "dog"
                         ]
                    ]
               }
          },
          {
               "cursor" : "BtreeCursor type_1",
               "nscanned" : 3461,
               "nscannedObjects" : 3461,
               "n" : 3137,
               "millis" : 247,
               "nYields" : 0,
               "nChunkSkips" : 0,
               "isMultiKey" : false,
               "indexOnly" : false,
               "indexBounds" : {
                    "role" : [
                         [
                              "cat",
                              "cat"
                         ]
                    ]
               }
          }
     ],
     "nscanned" : 3469,
     "nscannedObjects" : 3469,
     "n" : 3144,
     "millis" : 247
}
~~~

実際のクエリであれば、単一フィールド条件で `$or` を使うことはないと思うが、ソート条件などと組み合わさるとインデックスが効かなくなって全ドキュメントを走査し始めるので注意。

MongoDB のインデックスは B-Tree で実装されているようなので，RDB を扱ったことがあれば SQL でインデックスが使用されるために注意しなければいけない点とほぼ同様だと思われる。

