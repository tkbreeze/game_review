require 'net/http'
require 'uri'
require 'json'

# Twitch Helix API からゲームの視聴者数を取得するサービス
# IGDB と同じ Twitch Developer の認証情報を使用する
# 必要な環境変数: IGDB_CLIENT_ID, IGDB_CLIENT_SECRET
class TwitchTrendingService
  TWITCH_TOKEN_URL = 'https://id.twitch.tv/oauth2/token'
  TWITCH_API_BASE  = 'https://api.twitch.tv/helix'

  def initialize
    @client_id     = ENV.fetch('IGDB_CLIENT_ID')
    @client_secret = ENV.fetch('IGDB_CLIENT_SECRET')
    @access_token  = authenticate
  end

  # ゲームタイトルに対する現在の合計 Twitch 視聴者数を返す
  def fetch_viewer_count(game_title)
    twitch_game = find_twitch_game(game_title)
    return 0 unless twitch_game

    fetch_total_viewers(twitch_game['id'])
  rescue => e
    Rails.logger.warn("[TwitchTrendingService] #{game_title}: #{e.message}")
    0
  end

  private

  def authenticate
    uri = URI(TWITCH_TOKEN_URL)
    uri.query = URI.encode_www_form(
      client_id:     @client_id,
      client_secret: @client_secret,
      grant_type:    'client_credentials'
    )
    response = Net::HTTP.post(uri, '')
    data = JSON.parse(response.body)
    raise "Twitch OAuth認証失敗: #{data['message']}" if data['access_token'].nil?

    data['access_token']
  end

  def find_twitch_game(name)
    uri = URI("#{TWITCH_API_BASE}/games")
    uri.query = URI.encode_www_form(name: name)
    body = JSON.parse(get_request(uri).body)
    body.dig('data', 0)
  end

  def fetch_total_viewers(game_id)
    total  = 0
    cursor = nil

    loop do
      query = { game_id: game_id, first: 100 }
      query[:after] = cursor if cursor

      uri = URI("#{TWITCH_API_BASE}/streams")
      uri.query = URI.encode_www_form(query)
      body    = JSON.parse(get_request(uri).body)
      streams = body['data'] || []

      total  += streams.sum { |s| s['viewer_count'].to_i }
      cursor  = body.dig('pagination', 'cursor')
      break if cursor.nil? || streams.empty?
    end

    total
  end

  def get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.read_timeout = 10

    req = Net::HTTP::Get.new(uri)
    req['Client-ID']     = @client_id
    req['Authorization'] = "Bearer #{@access_token}"
    http.request(req)
  end
end
