require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if Rails.env.production?
    #本番環境
    config.storage :fog
    config.fog_provider = 'fog/aws'
    config.fog_directory  = 'rails-game-review'
    config.fog_public = false
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], # 環境変数
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], # 環境変数
      region: 'ap-northeast-1',
      path_style: true
    }
  else
    #本番環境以外
    config.storage :file
    config.enable_processing = false if Rails.env.test?
  end
end