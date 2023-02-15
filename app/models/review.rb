class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user
  enum good_point: {not_defined: 0, game_property: 1, graphic: 2, world: 3, contents: 4, BGM: 5}, _prefix: true
  enum bad_point: {not_defined: 0, game_property: 1, graphic: 2, world: 3, contents: 4, BGM: 5}, _prefix: true
  #一意性制約
  validates :user_id, uniqueness: {scope: :game_id}
  validates :play_hour, presence: true, numericality: {greater_than_or_eqaul_to: 0.0}
  validates :score, presence: true, numericality: {in: 0.0..10.0}
end
