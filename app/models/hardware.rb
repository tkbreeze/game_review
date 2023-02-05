class Hardware < ApplicationRecord
    has_many :game_hardwares, dependent: :destroy
    has_many :games, through: :game_hardwares, dependent: :destroy
end
