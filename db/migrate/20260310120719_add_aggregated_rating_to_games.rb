class AddAggregatedRatingToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :aggregated_rating, :float
  end
end
