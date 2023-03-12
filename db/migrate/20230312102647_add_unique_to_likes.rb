class AddUniqueToLikes < ActiveRecord::Migration[7.0]
  def change
    add_index :likes, [:user_id,:review_id], unique: true
  end
end
