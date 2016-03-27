---
layout: post
title:  "SQL クエリの結果を外部ファイルへ出力する方法"
date:   2010-11-12 01:19:07 UTC+9
category: database
tags: mysql sql
---


## SQL クエリの結果をファイル出力

### リダイレクトで出力先を指定する

ターミナルからリダイレクトを利用して、ファイルへ出力することができる。SQL クエリをファイルに用意しておき、以下のようなコマンドを実行する。

~~~sh
mysql -u user -p my_database < select.sql > output.tsv
~~~

### MySQL コマンドで外部ファイル出力する

MySQL へ接続して、コマンドラインツール上でSQL クエリを実行した結果を外部ファイルへ出力する事が出来る。

~~~sql
SELECT * FROM <table> INTO OUTFILE 'FILE_NAME';
~~~

#### カンマ区切りで出力する

正確な CSV 形式ではないので、カラム内のデータにカンマ (,) やダブルクォーテーション (") が含まれていると正確に吐き出せない可能性があります。

~~~sql
SELECT * FROM <table> INTO OUTFILE '/tmp/output.csv'
  FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    ESCAPED BY '\\'
  LINES TERMINATED BY '\r\n'
;
~~~

#### タブ区切りで出力する

~~~sql
SELECT * FROM <table> INTO OUTFILE '/tmp/output.tsv'
  FIELDS TERMINATED BY '\t'
  LINES TERMINATED BY '\n'
;
~~~
