---
layout: post
title:  "個人情報保護のためのHTTP キャッシュ設定まとめ"
date:   2013-12-21 06:55:43 UTC+9
category: engineering
tags: network http
---

## キャッシュコントロール設定

個人情報を扱う画面でのキャッシュ設定方法をまとめました。ユーザ側の操作の問題でもあるが、小難しい事なのである程度キャッシュコントロールして、エンジニア側で個人情報を保護しましょう。

### HTTP レスポンスヘッダー

`Cache-Control` でキャッシュアルゴリズムを明示的に指定する。`Cache-Control` はリクエスト/レスポンス連鎖上のすべてのキャッシングメカニズムが従わなければならない指示を記述するために使用されるヘッダーです。

#### Cache-Control 設定例

HTTP/1.0 キャッシュは、`Cache-Control` を実装せず、`Pragma: no-cache` しか実装していないかもしれないので合わせて指定しておくと良さそう。

```
Cache-Control: private, no-store, no-cache, must-revalidate
Pragma: no-cache
```

`Expires` や `Last-Modified` で過去時刻を指定する方法も無くはないが、キャッシュをさせない指定として必要なのは上記の2つ。

#### 参考URL

- [RFC2616 Hypertext Transfer Protocol -- HTTP/1.1](http://www.ietf.org/rfc/rfc2616.txt)
- [RFC 2616 日本語訳](http://www.studyinghttp.net/cgi-bin/rfc.cgi?2616)

### HTML の meta タグ

HTTP レスポンスヘッダーと同様に HTML の meta タグで設定できる。

#### 設定例

```html
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="expires" content="-1">
```

### 入力フォームのキャッシュ制御

入力の手間削減とのトレードオフになるが、少なくとも口座やクレジットカードの入力では設定した方が良いと思う。また、一部のブラウザ (Opera 10) で対応していない事もあるらしい。

#### フォーム全体に設定する場合

```html
<form method="post" action="example.cgi" autocomplete="off"></form>
```

#### 特定のフォームのみに設定する場合

```html
<input type="text" name="name" autocomplete="off" />
```

#### 参考URL

- [オートコンプリート機能が働くパターン - 2010-11-04](http://lab.hisasann.com/autocomplete/)

### Cookie や Web Strage の使い分けとセキュリティ設定

キャッシュコントロールではないが、Cookie, localStorage, sessionStorage などに不要な個人情報を直接書き込んでいないか。

#### Cookie のセキュリティ設定

あくまで補助的な仕組みだが、最低限は設定しておきましょう。

- Secure 属性
- 適切な有効期限の設定

#### Cookieの特長

- ドメイン毎にデータを保存 (SameOrigin の原則)
- String を保存
- ***HTTP リクエストで毎回サーバーに送信***
- JavaScript からアクセス可能
- ***有効期限がある (指定可能)***

#### localStorageの特長

- ドメイン毎にデータを保存 (SameOrigin の原則)
- String を保存
- ***HTTP リクエストで毎回サーバーに送信しない***
- JavaScript からアクセス可能
- ***有効期限が特にない***

#### sessionStorageの特長

- ドメイン毎にデータを保存 (SameOrigin の原則)
- String を保存
- ***HTTP リクエストで毎回サーバーに送信しない***
- JavaScript からアクセス可能
- ***有効期限はブラウザを閉じるまで***
