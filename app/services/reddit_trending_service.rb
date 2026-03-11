require 'net/http'
require 'uri'
require 'json'

# Reddit の公開 JSON API からゲームタイトルの直近1週間の投稿数を取得するサービス
# APIキー不要。User-Agent ヘッダーのみ必要。
class RedditTrendingService
  REDDIT_SEARCH_URL = 'https://www.reddit.com/search.json'

  # ゲームタイトルの直近1週間のReddit投稿数を返す（最大300件）
  def fetch_post_count(game_title)
    total = 0
    after = nil

    # 1ページ100件 × 最大3ページまで取得
    3.times do
      params = {
        q:     "\"#{game_title}\"",
        sort:  'new',
        t:     'week',
        limit: 100,
        type:  'link'
      }
      params[:after] = after if after

      uri = URI(REDDIT_SEARCH_URL)
      uri.query = URI.encode_www_form(params)

      body  = JSON.parse(get_request(uri).body)
      posts = body.dig('data', 'children') || []
      total += posts.size
      after  = body.dig('data', 'after')

      break if after.nil? || posts.empty?

      sleep 1 # Reddit レート制限対策（未認証は60req/min）
    end

    total
  rescue => e
    Rails.logger.warn("[RedditTrendingService] #{game_title}: #{e.message}")
    0
  end

  private

  def get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.read_timeout = 15

    req = Net::HTTP::Get.new(uri)
    req['User-Agent'] = 'GameReviewAggregator/1.0'
    req['Accept']     = 'application/json'
    http.request(req)
  end
end
