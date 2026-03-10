class Game < ApplicationRecord
  has_many :game_hardwares, dependent: :destroy
  has_many :hardwares, through: :game_hardwares, dependent: :destroy
  has_many :game_genres, dependent: :destroy
  has_many :genres, through: :game_genres
  has_many :reviews, dependent: :destroy

  mount_uploader :cover, CoverUploader
end
