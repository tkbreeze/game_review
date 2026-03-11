# 本アプリについて

公開先URL: [game-review-aggregator.net](https://game-review-aggregator.net)

#### 本アプリの概要
ゲームレビューを投稿するWebアプリケーションを、Railsを使用し、作りました。

開発の動機は、平均評価が低いゲームでも、個人的には非常に楽しめた経験にあります。これは、各プレイヤーが重視するゲームの要素が異なるためだと考えました。この気づきから、単なるスコアだけでなく、ゲームの各要素に対する詳細な評価を共有できるサイトがあれば、ユーザーが自分に合ったゲームをより見つけやすくなるのではないかと考えました。


## 機能一覧ならびに使用技術
### フロントエンド
* scss, erb, Bootstrap5

### サーバーサイド
* Ruby/Ruby on Rails7を使用
* ユーザー登録機能（devise）
* ユーザープロフィール画像登録機能（carrierwave）
* ゲームレビュー投稿機能
* ゲームレビューいいね機能
* ページネーション機能(kaminari)
* IGDB APIによるゲーム情報自動取得・毎日cronで新作ゲームをDB同期（whenever）
* ゲーム一覧の検索・ソート・フィルタ機能
  * タイトル検索（部分一致）
  * ソート: 発売日 / Metacriticスコア / ユーザースコア / 注目度
  * フィルタ: ジャンル・機種・メーカー・注目（組み合わせ可）
* 注目ゲーム機能（Twitch視聴者数 + Reddit投稿数によるトレンドスコア算出、6時間ごとcron更新）
* Metacritic（IGDB aggregated_rating）スコア表示
* 単体テスト(RSpec)
* 統合テスト(RSpec)

### インフラ
* AWS EC2サーバー
* AWS S3にユーザー画像・ゲームパッケージ画像を保存
* Amazon SESによるメール送信(アカウントデータ変更時)

## スクリーンショット
![Home画面](https://user-images.githubusercontent.com/120573270/223739992-db0a280c-fb04-4911-9392-f6b747042f2d.png "Home画面")

Home画面

![ゲーム詳細ページ](https://user-images.githubusercontent.com/120573270/223737643-350555bc-dfdf-4dc7-83ec-5e0419d069aa.png "ゲーム詳細ページ")

ゲーム詳細ページ

![アカウント詳細ページ](https://user-images.githubusercontent.com/120573270/223738603-4557cd30-5535-46db-baf1-e060eaba1f7f.png "アカウント詳細ページ")

アカウント詳細ページ

## ToDo
+ [x] ゲーム自動追加
+ [x] 検索・ソート・フィルタ機能
+ [x] 注目ゲーム機能（Twitch / Reddit）
+ [ ] ゲームニュース機能
