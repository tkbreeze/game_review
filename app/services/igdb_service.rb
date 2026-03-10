require 'net/http'
require 'uri'
require 'json'

# IGDB APIからゲーム情報を取得してDBに保存するサービス
# 事前に以下の環境変数が必要:
#   IGDB_CLIENT_ID     — Twitch Developer Consoleで発行したClient ID
#   IGDB_CLIENT_SECRET — 同Client Secret
class IgdbService
  TWITCH_TOKEN_URL = 'https://id.twitch.tv/oauth2/token'
  IGDB_BASE_URL    = 'https://api.igdb.com/v4'
  IGDB_COVER_URL   = 'https://images.igdb.com/igdb/image/upload/t_cover_big'

  def initialize
    @client_id     = ENV.fetch('IGDB_CLIENT_ID')
    @client_secret = ENV.fetch('IGDB_CLIENT_SECRET')
    @access_token  = authenticate
  end

  # 直近 days_ago 日間にリリースされたゲームを同期する
  def sync_new_games(days_ago: 1)
    games_data = fetch_games(days_ago: days_ago)
    synced = 0
    failed = 0

    games_data.each do |data|
      sync_game(data)
      synced += 1
    rescue => e
      Rails.logger.error("[IgdbService] game_id=#{data['id']} の同期に失敗: #{e.message}")
      failed += 1
    end

    Rails.logger.info("[IgdbService] 完了 — 成功: #{synced}, 失敗: #{failed}")
    { synced: synced, failed: failed }
  end

  private

  # Twitch OAuth でアクセストークンを取得
  def authenticate
    uri = URI(TWITCH_TOKEN_URL)
    uri.query = URI.encode_www_form(
      client_id:     @client_id,
      client_secret: @client_secret,
      grant_type:    'client_credentials'
    )
    response = Net::HTTP.post(uri, '')
    data = JSON.parse(response.body)
    raise "Twitch OAuth 認証失敗: #{data['message']}" if data['access_token'].nil?

    data['access_token']
  end

  # IGDB からゲーム一覧を取得
  # fields の内訳:
  #   name                         → games.title
  #   first_release_date           → games.release_date (Unix timestamp)
  #   platforms.name               → hardwares.name (正規化)
  #   genres.name                  → genres.name (正規化)
  #   involved_companies.*         → games.maker (publisher 優先, 次に developer)
  #   cover.image_id               → games.cover (CarrierWave でダウンロード保存)
  def fetch_games(days_ago: 1)
    since    = (Date.today - days_ago).to_time.to_i
    till_now = Time.now.to_i

    query = <<~QUERY.strip
      fields name,
             first_release_date,
             platforms.name,
             genres.name,
             involved_companies.company.name,
             involved_companies.developer,
             involved_companies.publisher,
             cover.image_id;
      where first_release_date >= #{since} & first_release_date <= #{till_now};
      sort first_release_date desc;
      limit 500;
    QUERY

    post_igdb('/games', query)
  end

  # IGDB API への POST リクエスト
  def post_igdb(endpoint, body)
    uri  = URI("#{IGDB_BASE_URL}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl     = true
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri)
    request['Client-ID']     = @client_id
    request['Authorization'] = "Bearer #{@access_token}"
    request['Content-Type']  = 'text/plain'
    request.body = body

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      raise "IGDB API エラー #{response.code}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  # 1件のゲームを DB に保存（存在すれば更新、なければ新規作成）
  def sync_game(data)
    game = Game.find_or_initialize_by(igdb_id: data['id'])

    game.title        = data['name']
    game.release_date = Time.at(data['first_release_date']).to_date if data['first_release_date']
    game.maker        = extract_maker(data['involved_companies'])

    game.save!

    sync_hardwares(game, data['platforms'])
    sync_genres(game, data['genres'])
    sync_cover(game, data['cover'])

    game
  end

  # publisher → developer の順で会社名を取得
  def extract_maker(involved_companies)
    return nil if involved_companies.blank?

    publisher = involved_companies.find { |c| c['publisher'] }
    developer = involved_companies.find { |c| c['developer'] }
    company   = publisher || developer
    company&.dig('company', 'name')
  end

  # platforms → hardwares テーブルに正規化して保存
  def sync_hardwares(game, platforms)
    return if platforms.blank?

    platforms.each do |platform|
      hardware = Hardware.find_or_create_by(name: platform['name'])
      game.hardwares << hardware unless game.hardwares.include?(hardware)
    end
  end

  # genres テーブルに正規化して保存
  def sync_genres(game, genres_data)
    return if genres_data.blank?

    genres_data.each do |genre_data|
      genre = Genre.find_or_create_by(name: genre_data['name'])
      game.genres << genre unless game.genres.include?(genre)
    end
  end

  # パッケージ画像を IGDB からダウンロードして CarrierWave で保存
  # 既にカバー画像がある場合はスキップ
  def sync_cover(game, cover_data)
    return if cover_data.blank? || cover_data['image_id'].blank?
    return if game.cover.present?

    image_id  = cover_data['image_id']
    cover_url = "#{IGDB_COVER_URL}/#{image_id}.jpg"

    # remote_*_url= を使うと CarrierWave が URL から拡張子を正しく取得する
    game.remote_cover_url = cover_url
    game.save!
  rescue CarrierWave::DownloadError, SocketError, Net::OpenTimeout => e
    Rails.logger.warn("[IgdbService] カバー画像のダウンロード失敗 game_id=#{game.igdb_id}: #{e.message}")
  end
end
