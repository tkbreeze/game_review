class Like < ApplicationRecord
  belongs_to :user
  belongs_to :review
  #一意性制約
  validates :user_id, uniqueness: {scope: :review_id}
end
