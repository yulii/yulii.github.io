---
layout: post
title:  "Mongoid のクエリを最適化する"
date:   2012-07-30T21:22:08+0900
category: engineering
tags: ruby mongodb performance
---

Mongoid で発行されるクエリを最適化するために知っておきたい機能

## only メソッドで必要最低限のフィールドを取得

取得するフィールドを `Mongoid::Criteria#only` で絞れる

```ruby
Users.only(:name)
```

MongoDB の `find()` クエリの第２引数の指定に相当する。

```javascript
> db.users.find({});
{
  "_id"      : ObjectId("501676ca7f8e725b9caa7c31"),
  "name"     : "yulii",
  "profile"  : "Director of Web Development and Engineering",
  "location" : "@ in AAAA ::1",
  "url"      : "https://yulii.github.io/"
}
> db.users.find({}, { name : 1 });
{
  "_id"      : ObjectId("501676ca7f8e725b9caa7c31"),
  "name"     : "yulii"
}
```

クエリ実行時間が劇的に速くなるわけではないが、データ通信量を減らすためにやっておくと良い。

## includes メソッドで Eager Loading

どうしても Relation が必要なら、`Mongoid::Criteria#includes` で Eager Loading すると良い。

```ruby
Users.includes(:friend)
```

Relation じゃないときは、クエリを2回に分けて実行する。`Mongoid::Criteria#only` で `id` を取得して、欲しいデータを取得する

```ruby
ids = Users.find().only(:id).map(&:id)
friends = Friends.find(ids)
```

## 参考URL

[Mongoid - Object-Document-Mapper (ODM) for MongoDB written in Ruby](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/#ruby-mongoid-tutorial)
