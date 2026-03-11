class AddTrendingToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :twitch_viewer_count, :integer, default: 0
    add_column :games, :reddit_post_count,   :integer, default: 0
    add_column :games, :trending_score,      :float,   default: 0.0
    add_column :games, :trending_updated_at, :datetime
  end
end
