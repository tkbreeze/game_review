class GameHardware < ApplicationRecord
  belongs_to :game
  belongs_to :hardware
end
