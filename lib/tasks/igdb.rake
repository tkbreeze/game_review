namespace :igdb do
  desc '直近1日にリリースされた新作ゲームを IGDB から取得して DB に保存する'
  task sync_new_games: :environment do
    Rails.logger.info('[igdb:sync_new_games] 開始')

    result = IgdbService.new.sync_new_games
    puts "完了 — 成功: #{result[:synced]}, 失敗: #{result[:failed]}"

    Rails.logger.info("[igdb:sync_new_games] 終了 #{result.inspect}")
  end

  desc '過去 N 日分のゲームを一括同期する（例: rake igdb:backfill DAYS=7）'
  task backfill: :environment do
    days = (ENV['DAYS'] || 7).to_i
    Rails.logger.info("[igdb:backfill] 過去 #{days} 日分を同期開始")

    result = IgdbService.new.sync_new_games(days_ago: days)
    puts "完了 — 成功: #{result[:synced]}, 失敗: #{result[:failed]}"

    Rails.logger.info("[igdb:backfill] 終了 #{result.inspect}")
  end
end
