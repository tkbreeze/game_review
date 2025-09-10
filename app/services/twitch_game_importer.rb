require 'net/http'
require 'json'
require 'open-uri'
require 'fileutils'

class TwitchGameImporter
  TOKEN_URL = URI('https://id.twitch.tv/oauth2/token')
  IGDB_ENDPOINT = URI('https://api.igdb.com/v4/games')
  IMAGE_BASE_URL = 'https://images.igdb.com/igdb/image/upload/t_cover_big/'

  def initialize(client_id: ENV.fetch('TWITCH_CLIENT_ID'), client_secret: ENV.fetch('TWITCH_CLIENT_SECRET'))
    @client_id = client_id
    @client_secret = client_secret
  end

  def call
    token = fetch_access_token
    games = fetch_new_games(token)
    games.each do |data|
      title = data['name']
      maker = data.dig('involved_companies', 0, 'company', 'name')
      release_date = Time.at(data['first_release_date']).to_date if data['first_release_date']
      platforms = Array(data['platforms'])
      genres = Array(data['genres'])
      image_id = data.dig('cover', 'image_id')

      game = Game.find_or_initialize_by(title: title)
      game.update!(maker: maker, release_date: release_date)

      platforms.each do |platform|
        hardware = Hardware.find_or_create_by(name: platform['name'])
        GameHardware.find_or_create_by(game: game, hardware: hardware)
      end

      genres.each do |g|
        genre = Genre.find_or_create_by(name: g['name'])
        GameGenre.find_or_create_by(game: game, genre: genre)
      end

      if image_id
        image_url = "#{IMAGE_BASE_URL}#{image_id}.jpg"
        save_cover_image(game.id, image_url)
      end
    end
  end

  private

  def fetch_access_token
    res = Net::HTTP.post_form(TOKEN_URL, {
      client_id: @client_id,
      client_secret: @client_secret,
      grant_type: 'client_credentials'
    })
    JSON.parse(res.body).fetch('access_token')
  end

  def fetch_new_games(token)
    request = Net::HTTP::Post.new(IGDB_ENDPOINT)
    request['Client-ID'] = @client_id
    request['Authorization'] = "Bearer #{token}"
    since = 7.days.ago.to_i
    request.body = <<~QUERY
      fields name, first_release_date, involved_companies.company.name, platforms.name, genres.name, cover.image_id;
      sort first_release_date desc;
      where first_release_date != null & first_release_date > #{since};
      limit 50;
    QUERY

    response = Net::HTTP.start(IGDB_ENDPOINT.host, IGDB_ENDPOINT.port, use_ssl: true) do |http|
      http.request(request)
    end
    JSON.parse(response.body)
  end

  def save_cover_image(game_id, url)
    path = Rails.root.join('app', 'assets', 'images', "#{game_id}.jpg")
    return if File.exist?(path)

    FileUtils.mkdir_p(path.dirname)
    URI.open(url) do |image|
      File.binwrite(path, image.read)
    end
  rescue StandardError => e
    Rails.logger.warn("Failed to save image for game #{game_id}: #{e.message}")
  end
end
