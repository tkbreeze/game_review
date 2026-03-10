# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A game review aggregator (Rails app) where users post multi-dimensional reviews — rating games on individual aspects (graphics, world design, story, BGM, etc.) rather than a single score. Deployed on AWS EC2 at game-review-aggregator.net.

## Commands

```bash
# Development server (starts web + JS watch + CSS watch concurrently)
foreman start

# Individual processes
bin/rails server
yarn build --watch
yarn build:css --watch

# Build assets once
yarn build
yarn build:css

# Tests
bundle exec rspec                        # All tests
bundle exec rspec spec/models/           # Model tests only
bundle exec rspec spec/requests/         # Request tests only
bundle exec rspec spec/system/           # System/E2E tests (requires Chrome)
bundle exec rspec spec/path/to/file_spec.rb  # Single test file

# Database
bin/rails db:migrate
bin/rails db:seed

# IGDB同期
bin/rails igdb:sync_new_games        # 直近1日の新作ゲームを同期
bin/rails igdb:backfill DAYS=7       # 過去N日分を一括同期

# cron登録（本番サーバーで実行）
bundle exec whenever --update-crontab   # crontabに登録
bundle exec whenever                    # 内容確認
bundle exec whenever --clear-crontab    # 削除
```

## Architecture

**Stack:** Rails 7 / Ruby 3.2 / SQLite (dev) / MySQL (prod) / Stimulus + Turbo / Bootstrap 5 / ESBuild + Sass

### Data Model

- `User` — Devise auth, avatar via CarrierWave (S3 in prod), has many reviews and likes
- `Game` — title/maker/release_date/igdb_id/cover, belongs to many `Hardware` and `Genre` via join tables; `igdb_id` で重複防止、`cover` は CarrierWave (CoverUploader)
- `Review` — belongs to game + user; score (0–10), play_hour, title, body, `good_point`/`bad_point` (enums), `classification_flag`; one review per user per game enforced at DB + model level
- `Like` — join between user and review; one like per user per review

### Key Enums

`Review#good_point` and `#bad_point`: `not_defined / nothing / game_property / graphic / world / contents / BGM`
Enum prefix is set (e.g., `review.good_point_graphic?`).

### Controllers

- `GamesController#index` — filters by hardware param
- `GamesController#show` — aggregates review data for Chartkick pie charts; calculates score color (≥8 green, ≥4 yellow, <4 red)
- `ReviewsController` — nested under `/games/:game_id/reviews`; owner-only edit/delete
- `LikesController` — `POST /like/:id` / `DELETE /like/:id`; users cannot like their own reviews
- Custom Devise controllers under `app/controllers/users/`

### Authentication & Authorization

- Devise handles registration, sessions, password reset, email confirmation
- `ApplicationController` sanitizes `:name` and `:avatar` as permitted Devise params
- Authorization is inline in controllers (no separate authorization library)

### Localization

- Default locale: Japanese (`:ja`), timezone: Tokyo
- Field error rendering overridden to emit HTML-safe content (see `config/initializers/`)

### Assets

- JavaScript: Stimulus controllers in `app/javascript/`, compiled to `app/assets/builds/`
- CSS: SCSS in `app/assets/stylesheets/`, compiled to `app/assets/builds/`
- Images: CarrierWave uploads; local in dev (`public/uploads/`), S3 in prod
  - `AvatarUploader` — ユーザーアバター; thumb 50×50, thumb40 40×40
  - `CoverUploader` — ゲームパッケージ画像; thumb 120×160

### IGDB自動同期

- `app/services/igdb_service.rb` — Twitch OAuthでトークン取得 → `https://api.igdb.com/v4/games` から新作ゲームを取得してDB保存
- 正規化: platforms → `hardwares`, genres → `genres`（`find_or_create_by`）
- パッケージ画像: `remote_cover_url=` で CarrierWave がダウンロード・保存
- cron: `config/schedule.rb`（whenever gem）で毎日午前2時に `igdb:sync_new_games` 実行
- 必要な環境変数: `IGDB_CLIENT_ID`, `IGDB_CLIENT_SECRET`（Twitch Developer Console で発行）

### Testing Conventions

- RSpec + FactoryBot; factories in `spec/factories/`
- System tests use Capybara + Selenium (Chrome)
- `rails_helper.rb` configures FactoryBot and Devise test helpers
