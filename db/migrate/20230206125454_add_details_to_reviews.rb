class AddDetailsToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :play_hour, :float, null:false
    add_column :reviews, :body, :text
    add_column :reviews, :score, :decimal, null:false, precision:4, scale:1
    add_column :reviews, :classification_flag, :string, default: false
  end
end
