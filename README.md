# 本アプリについて

公開先URL: [www.game-review-aggregator.net](https://www.game-review-aggregator.net)

#### 本アプリの概要
ゲームレビューを投稿するWebアプリケーションを、Railsを使用し、作りました。

私は、ゲームが趣味で、自分の好きなゲームにレビューを書くことや他の人のレビュを見ることが好きなのですが、海外ではレビュー投稿サイトとしてMetaScoreがあるのですが、日本では、あまりそのようなサイトがないため、作成しました。

## 機能一覧ならびに使用技術
### フロントエンド
* scss, erb, Bootstrap5

### サーバーサイド
* Ruby/Ruby on Rails7を使用
* ユーザー登録機能（devise）
* ユーザープロフィール画像登録機能（carrierwave）
* ゲームレビュー投稿機能
* ページネーション機能(kaminari)
* 単体テスト(RSpec)
* 統合テスト(RSpec)

### インフラ
* AWS EC2サーバー
* AWS S3にユーザー画像を保存
* Amazon SESによるメール送信

## スクリーンショット
![Home画面](https://user-images.githubusercontent.com/120573270/223739992-db0a280c-fb04-4911-9392-f6b747042f2d.png "Home画面")

Home画面

![ゲーム詳細ページ](https://user-images.githubusercontent.com/120573270/223737643-350555bc-dfdf-4dc7-83ec-5e0419d069aa.png "ゲーム詳細ページ")

ゲーム詳細ページ

![アカウント詳細ページ](https://user-images.githubusercontent.com/120573270/223738603-4557cd30-5535-46db-baf1-e060eaba1f7f.png "アカウント詳細ページ")

アカウント詳細ページ