class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :reviews
  has_many :likes
  validates :name, presence: true
  mount_uploader :avatar, AvatarUploader

  def liked_by?(review_id)
    likes.where(review_id: review_id).exists?
  end
end