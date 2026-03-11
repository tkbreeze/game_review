namespace :trending do
  desc "Twitch視聴者数・Reddit投稿数を取得してゲームのトレンドスコアを更新する"
  task update: :environment do
    twitch = TwitchTrendingService.new
    reddit = RedditTrendingService.new
    updated = 0
    failed  = 0

    Game.find_each do |game|
      twitch_count = twitch.fetch_viewer_count(game.title)
      reddit_count = reddit.fetch_post_count(game.title)

      # Twitch視聴者数とReddit投稿数を合算してスコア化
      # Reddit投稿数に重みを付けて均衡させる
      score = twitch_count + reddit_count * 100

      game.update!(
        twitch_viewer_count: twitch_count,
        reddit_post_count:   reddit_count,
        trending_score:      score,
        trending_updated_at: Time.current
      )
      updated += 1
    rescue => e
      Rails.logger.error("[trending:update] #{game.title}: #{e.message}")
      failed += 1
    end

    puts "完了 — 更新: #{updated}, 失敗: #{failed}"
  end
end
