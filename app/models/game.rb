class Game < ApplicationRecord
    has_many :game_hardwares, dependent: :destroy
    has_many :hardwares, through: :game_hardwares, dependent: :destroy
    has_many :reviews, dependent: :destroy
end
