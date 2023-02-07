class AddPointsToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :good_point, :integer, default:0
    add_column :reviews, :bad_point, :integer, default:0
  end
end
