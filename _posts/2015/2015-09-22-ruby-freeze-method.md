---
layout: post
title:  "Ruby の定数やfreeze の扱い方が難しい"
date:   2015-09-22 16:49:21 UTC+9
category: engineering
tags: ruby
---

Ruby の定数はミュータブルのため、目立たないバグを埋め込む可能性がある。
`Object#freeze` を使うとオブジェクトをイミュータブル（状態変更不可）にできる。

## Ruby の定数

Ruby 以外の言語では再代入させない場合があるが、Ruby の定数は Warning を出しつつも再代入できる。

```ruby
irb(main):001:0> CONST = "constant string"
=> "constant string"
irb(main):002:0> CONST = "overwrite!"
(irb):2: warning: already initialized constant CONST
(irb):1: warning: previous definition of CONST was here
=> "overwrite!"
```

破壊的メソッドも問題なく実行されるため、定義済みの定数の内容（オブジェクト）を変更できる。

```ruby
irb(main):001:0> CONST = "constant string"
=> "constant string"
irb(main):002:0> CONST << " destruct!"
=> "constant string destruct!"
```

これが意図した動作でない場合は `Object#freeze` を使って制御しよう。

## オブジェクトの凍結

オブジェクトを凍結すると __"破壊的な操作"__ ができなくなります。

```ruby
irb(main):001:0> var = "string".freeze
=> "string"
irb(main):002:0> var.frozen?
=> true
irb(main):003:0> var << " destruct!"
RuntimeError: can't modify frozen String
```

一度凍結されたオブジェクトは解凍できないので、どうしても変更したい場合は `Object#dup` を使ってオブジェクトを複製する必要があります。

## freeze メソッド

対象のオブジェクトに対する __"破壊的な操作"__ を禁止するだけなのでオブジェクトの参照変更（代入）はできます。
いくつか不思議な動きがありますが、 `freeze` はあくまでもオブジェクトを凍結するだけです。

### freeze 後の代入

定数定義に合わせてオブジェクトを凍結しても、本当にやりたかった定数の状態にはならないのです。

```ruby
irb(main):001:0> CONST="constant string".freeze
=> "constant string"
irb(main):002:0> CONST.frozen?
=> true
irb(main):003:0> CONST << " destruct!"
RuntimeError: can't modify frozen String
irb(main):004:0> CONST="overwrite!"
(irb):4: warning: already initialized constant CONST
(irb):1: warning: previous definition of CONST was here
=> "overwrite!"
```

### freeze した配列やハッシュの状態変更

配列やハッシュはそのまま `freeze` しても、本当にやりたかった凍結の状態にはならないのです。

```ruby
irb(main):001:0> list = ['apple', 'banana', 'cherry'].freeze
=> ["apple", "banana", "cherry"]
irb(main):002:0> list << 'add'
RuntimeError: can't modify frozen Array
irb(main):003:0> list.map! {|x| x << ' rotting' }
RuntimeError: can't modify frozen Array
irb(main):004:0> list.map {|x| x << ' rotting' }
=> ["apple rotting", "banana rotting", "cherry rotting"]
irb(main):005:0> list
=> ["apple rotting", "banana rotting", "cherry rotting"]
```

`map!` は破壊的操作なので例外が発生するが、 `map` の中で配列の要素に対する破壊的操作は実行できる。
`freeze` したのはあくまでも配列オブジェクトで、それを構成する文字列オブジェクトまでは凍結されない。

## freeze で正しくイミュータブルにする

### イミュータブルな定数を定義する

Class やModule ごと freeze することで、代入とオブジェクトの破壊を防ぐことができる。
少々、冗長な定義になるが Ruby としてはそういうことらしい。

```ruby
irb(main):001:0> class MyClass
irb(main):002:1>   CONST = 'constant'.freeze
irb(main):003:1>   freeze
irb(main):004:1> end
=> MyClass
irb(main):005:0> MyClass.frozen?
=> true
irb(main):006:0> MyClass::CONST.frozen?
=> true
irb(main):007:0> MyClass::CONST
=> "constant"
irb(main):008:0> MyClass::CONST << ' overwrite!'
RuntimeError: can't modify frozen String
irb(main):009:0> MyClass::CONST = 'overwrite!'
RuntimeError: can't modify frozen #<Class:MyClass>
```

Class やModule を凍結するときの注意としては、オープンクラスとしての恩恵が得られなくなる。
Class もしくはModule の状態変更ができないというのは、定数やメソッドを定義できない状態を指す。

```ruby
irb(main):001:0> class MyClass
irb(main):002:1>   CONST = 'constant'.freeze
irb(main):003:1>   freeze
irb(main):004:1>
irb(main):005:1*   def func
irb(main):006:2>     true
irb(main):007:2>   end
irb(main):008:1> end
RuntimeError: can't modify frozen class
```

必要なオブジェクトが定義される前に `freeze` するとおかしなことになる。ということで、使いどころに注意！

### イミュータブルな配列やハッシュを定義する

配列やハッシュを構成する要素を凍結すれば良いだけ。

#### 配列を要素ごと freeze する

やはり冗長な定義だが、諦めて `.map(&:freeze)` すればOK.

```ruby
irb(main):001:0> list = ['apple', 'banana', 'cherry'].map(&:freeze).freeze
=> ["apple", "banana", "cherry"]
irb(main):002:0> list.map! {|x| x << ' rotting' }
RuntimeError: can't modify frozen Array
irb(main):003:0> list.map {|x| x << ' rotting' }
RuntimeError: can't modify frozen String
```

#### ハッシュを要素ごと freeze する

どうしても冗長な定義だが、頑張って `freeze` する。

```ruby
irb(main):001:0> hash = { a: 'apple', b: 'banana', c: 'cherry' }.freeze
=> {:a=>"apple", :b=>"banana", :c=>"cherry"}
irb(main):002:0> hash.each_value(&:freeze)
=> {:a=>"apple", :b=>"banana", :c=>"cherry"}
irb(main):003:0> hash.each_value {|v| v << ' rotting' }
RuntimeError: can't modify frozen String
```

一行で定義できなくて、そろそろツライ。
