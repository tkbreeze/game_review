class AddIgdbFieldsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :igdb_id, :integer
    add_column :games, :cover, :string
    add_index :games, :igdb_id, unique: true
  end
end
