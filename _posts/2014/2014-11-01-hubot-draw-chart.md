---
layout: post
title:  "Hubot にグラフを描かせてみた (PhantomJS + Chart.js => PNG 画像化)"
date:   2014-11-01 14:40:23 UTC+9
category: engineering
tags: javascript nodejs hubot
---


Hubot を使ってグラフ画像を生成するスクリプトを作ってみました。Heroku + PhantomJS + Chart.js で動きます。

## PhantomJS + Chart.js => PNG 画像化

ざっくりと動作内容をまとめると

0. 子プロセスを生成し、PhantomJS を起動
0. PhantomJS でHTML ドキュメント (`canvas`) を生成
0. Chart.js を使って `canvas` 内でグラフを描画
0. グラフのレンダリング完了後 (`onAnimationComplete`) に画像化
0. `/tmp` ディレクトリにグラフ画像を保存 (Heroku の制約)
0. `robot.router` を使って `/tmp` 内の画像URL を発行

PhantomJS で処理しているスクリプトは [module/phantomjs-script.coffee](https://github.com/libinc/hubot-scripts/blob/master/module/phantomjs-script.coffee) です。

## インストール

npm では配布していないので、下記の方法でインストールしてください。（※余計なスクリプトも入るので、嫌な方は個別にファイルコピーしてください）

### package.json の依存ライブラリに追記

```
"dependencies": {
  "libinc-hubot": "libinc/hubot-scripts"
}
```

### external-scripts.json に追記

```
["libinc-hubot"]
```

## Hubot コマンドの使い方

あまりそのまま使うことはない想定です (`data` の指定を人がタイプする物じゃない！)。Hubot コマンドのソースは [scripts/chart.coffee](https://github.com/libinc/hubot-scripts/blob/master/scripts/chart.coffee) です。

### コマンド形式

```
hubot chart <type> <data>
```

#### 引数

[Chart.js のドキュメント](http://www.chartjs.org/docs/) を参考に以下の2つを指定します。

- type : グラフ形式の名称 (Chart.js の対応しているクラス名)
- data : グラフ描画に使うデータ (JSON 形式の文字列)

### コマンド例

例えば、棒グラフを描くには

```
hubot chart bar {"labels":["January","February","March","April","May","June","July"],"datasets":[{"label":"My First dataset","fillColor":"rgba(220,220,220,0.5)","strokeColor":"rgba(220,220,220,0.8)","highlightFill":"rgba(220,220,220,0.75)","highlightStroke":"rgba(220,220,220,1)","data":[65,59,80,81,56,55,40]},{"label":"My Second dataset","fillColor":"rgba(151,187,205,0.5)","strokeColor":"rgba(151,187,205,0.8)","highlightFill":"rgba(151,187,205,0.75)","highlightStroke":"rgba(151,187,205,1)","data":[28,48,40,19,86,27,90]}]}
```

という感じです。

## Hubot コマンドに組み込む

Node とか npm のお作法を知らないので、何か荒々なのですが `ChartImage` というモジュールで共通化してます。

### 実装手順

API などで取得したデータをグラフ画像にして返却する場合、

0. `require('../node_modules/libinc-hubot/module/chart_image')` で呼び出し
0. API のレスポンスからグラフ用のデータ (Object) を作成
0. `JSON#stringify` でJSON 形式に変換して `ChartImage#generate`

という処理イメージです。

```
ChartImage = require('../node_modules/libinc-hubot/module/chart_image')

module.exports = (robot) ->
  robot.respond /hoge( me)?/i, (msg) ->
    data = (API からデータを取ってくる)
    chart = new ChartImage()
    chart.generate "pie", JSON.stringify(data), (err, stdout, stderr) ->
      if err
        msg.send "#{err.name}: #{err.message}"
      filename = encodeURIComponent(chart.filename)
      msg.send "#{robot.helper.url()}/hubot/charts/#{filename}"
```

## 気になるところ（今後の拡張）

- `/tmp` ディレクトリなので、画像データを永続的に保持できない
    - AWS のS3 に投げるように拡張しようと検討中
- `ChartImage` を使って拡張するとき、URL を隠蔽できていない (Callback が冗長)
    - `ChartImage` 内で画像のURL を返却できるようにしたい

とかとか、気の利かない部分が多々あるので粛々と対応するつもり (誰かプルリクくれないかな)
