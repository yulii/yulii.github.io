---
layout: post
title:  "PHP の比較演算子 '==' の妙"
date:   2008-11-17 12:07:38 UTC+9
category: engineering
tags: php
---

## 比較演算子の気をつけたい仕様

PHP の比較演算子 `==` の結果が直感的でないものや他言語と違う結果になる。

### null の正体

ゼロと null 比較の曖昧さ。`$x = 0;` としたときに、以下のような比較結果が返ってくる。

#### true となる比較

```php
$x == 0
$x === 0
$x == null // コレが通ってしまう
```

#### false となる比較

```php
$x === null
```

#### 比較コード null.php

適当に値を比較してみた。

```php
<?php
echo null;

$x = array();
if ($x == 0) {
    echo "x == 0\n";
}
if ($x === 0) {
    echo "x === 0\n";
}
if ($x == null) {
    echo "x == null\n";
}
if ($x === null) {
    echo "x === null\n";
}

$y = 0;
if ($y == 0) {
    echo "y == 0\n";
}
if ($y === 0) {
    echo "y === 0\n";
}
if ($y == null) {
    echo "y == null\n";
}
if ($y === null) {
    echo "y === null\n";
}

$z = array(0);
if ($z == 0) {
    echo "z == 0\n";
}
if ($z === 0) {
    echo "z === 0\n";
}
if ($z == null) {
    echo "z == null\n";
}
if ($z === null) {
    echo "z === null\n";
}
?>
```

実行結果

```sh
$ php null.php
x == null
y == 0
y === 0
y == null
```

### 文字列比較

整数値にキャストされてしまう場合があるので注意が必要です。

>整数値を文字列と比較する際、文字列が 数値に変換されます。 数値形式の文字列を比較する場合、それは整数として比較されます。これらの ルールは、 switch 文にも適用されます。
>
><cite>[比較演算子 - PHP マニュアル](http://www.php.net/manual/ja/language.operators.comparison.php)</cite>

#### 比較コード string.php

```php
<?php
if (0 == 'str') {
    echo "'str' == 0\n";
}
if (true == 'str') {
    echo "'str' == true\n";
}
if ('str' == 'str') {
    echo "'str' == 'str'\n";
}
?>
```

実行結果

```sh
$ php string.php
'str' == 0
'str' == true
'str' == 'str'
```

文字列比較は、以下のような形で比較したほうが良いです。

```php
$a === $b
strcmp($a,$b) == 0
```

### 比較演算 `===`

値の型までチェックして比較してくれます。配列の場合、各要素も比較されます。

#### 変数の型をチェック

```php
<?php
$x = array(
  'p' => '123',
  'q' => 'w',
);
$y = array(
  'p' => 123,
  'q' => 'w',
);
var_dump($x == $y);
var_dump($x === $y);
?>
```

実行結果

```
bool(true)
bool(false)
```

#### 変数の順序をチェック

```php
<?php
$x = array(
  'p' => 'a',
  'q' => 'b',
  'r' => 'c',
);
$y = array(
  'q' => 'b',
  'p' => 'a',
  'r' => 'c',
);
var_dump($x == $y);
var_dump($x === $y);
?>
```

実行結果

```
bool(true)
bool(false)
```
