set :output, "log/cron.log"

# Fetch new games once per day
every 1.day do
  rake "twitch:fetch_new_games"
end
