# whenever gem の設定ファイル
# crontab への反映: bundle exec whenever --update-crontab
# crontab の確認:   bundle exec whenever
# crontab の削除:   bundle exec whenever --clear-crontab

set :output, Rails.root.join('log/cron.log').to_s

# 毎日午前2時に新作ゲームを同期
every 1.day, at: '2:00 am' do
  rake 'igdb:sync_new_games'
end
