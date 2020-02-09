---
layout: post
title:  "カッコいいグラフを描けるJavaScript ライブラリまとめ"
date:   2014-12-14T15:10:54+0900
category: engineering
tags: javascript
---

[40 JavaScript Chart and Graph Libraries](http://jqueryhouse.com/javascript-chart-and-graph-libraries/) からいくつかピックアップ

## 人気のライブラリ

人気のあるライブラリを[JavaScripting.com - The Database of JavaScript Libraries](https://www.javascripting.com/data) でチェックしてみました。[The Ruby Toolbox](https://www.ruby-toolbox.com/) みたいにJavaScript のライブラリの人気度合いをチェックできるサイトです。他にもあるのかな？

### [D3.js](http://d3js.org/)

データを可視化する定番ツールで、これを使えば描けないものが無いくらいに充実している。D3.js をラップしてくれているライブラリもあるみたいなので、用途によっては [dc.js](https://github.com/dc-js/dc.js) や[C3.js](http://c3js.org/) などを利用するのも良さそう。

### [Chart.js](http://www.chartjs.org/)

棒グラフや円グラフなどいわゆるチャートに特化したライブラリです。良い感じのデザインのチャートが簡単に描けます。個人的な一押しツールで、[Hubot にグラフを描かせてみた (PhantomJS + Chart.js => PNG 画像化)](http://yulii.net/entries/61)でも利用している。

### [Sigma.js](http://sigmajs.org/)

ネットワーク図のようなグラフを描くのに向いているライブラリです。使った事が無いので詳細はよく分かりません。Canvas や WebGL を利用しているらしく、アニメーションが良い感じです。

### [Highcharts](http://www.highcharts.com/)

デザインがイケているので、昔はよく使ってました。商用ライセンスです。
