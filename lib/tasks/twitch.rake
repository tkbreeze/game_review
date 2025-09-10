namespace :twitch do
  desc 'Fetch new games from IGDB via Twitch'
  task fetch_new_games: :environment do
    TwitchGameImporter.new.call
  end
end
