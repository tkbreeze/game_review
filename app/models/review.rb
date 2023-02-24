class Review < ApplicationRecord
  belongs_to :game
  belongs_to :user
  enum good_point: {not_defined: 0, nothing: 1, game_property: 2, graphic: 3, world: 4, contents: 5, BGM: 6}, _prefix: true
  enum bad_point: {not_defined: 0, nothing: 1, game_property: 2, graphic: 3, world: 4, contents: 5, BGM: 6}, _prefix: true
  #一意性制約
  validates :user_id, uniqueness: {scope: :game_id}
  validates :play_hour, presence: true, numericality: {greater_than_or_equal_to: 0.0}
  validates :score, presence: true, numericality: {in: 0.0..10.0}
  #レビュー内容がある場合、タイトルは必須
  validates :title, presence: {message: "は、レビュー内容があるときは、必須です"}, if: :body_present?
  #タイトルがある場合、レビュー内容は必須
  validates :body, presence: {message: "は、タイトルがあるときは、必須です"}, if: :title_present?

  def title_present?
    title.present?
  end

  def body_present?
    body.present?
  end
end
