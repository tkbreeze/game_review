class ChangeTitleDefaultOnReviews < ActiveRecord::Migration[7.0]
  def change
    change_column_default :reviews, :title, from: "なし", to: nil
  end
end
