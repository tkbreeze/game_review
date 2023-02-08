class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user
  enum good_point: {not_defined: 0, game_property: 1, graphic: 2, world: 3, contents: 4, BGM: 5}, _prefix: true
  enum bad_point: {not_defined: 0, game_property: 1, graphic: 2, world: 3, contents: 4, BGM: 5}, _prefix: true
  validates :user_id, uniquness: {scope: :game_id}
end
