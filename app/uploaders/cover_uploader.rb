class CoverUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    "/images/" + [version_name, "default_cover.jpg"].compact.join('_')
  end

  # パッケージ画像サムネイル（ゲーム一覧用）
  version :thumb do
    process resize_to_fill: [120, 160, "North"]
  end
end
