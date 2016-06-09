---
layout: post
title:  "ライブ配信サーバー構築 〜 Web サーバー (JW Player) の設定 〜"
date:   2009-11-10 07:34:33 UTC+9
category: javascript
tags: ffmpeg
---

## ライブ映像を表示する Web サーバーの設定

普通に HTML が見られるように設定するだけ。

### JW Player の埋め込みスニペット

JW Player で再生させる場合は、HTML の表示したい場所に要素を追加する。

```html
<div id="flashStreaming">Loading ...</div>
```

#### Player の読み込みスクリプト

URL 部分は、配信サーバー (FFserver) の設定に合わせる。 `write` で DOM の `id` を指定する。

```javascript
window.onload = function() {
    var fs = new SWFObject('jwplayer.swf','fsplayer','640','480','9');
    fs.addParam('allowfullscreen','true');
    fs.addParam('flashvars','file=http://127.0.0.1:8090/streaming.flv');
    fs.write('flashStreaming');
};
```

