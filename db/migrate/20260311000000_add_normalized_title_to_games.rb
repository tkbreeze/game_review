class AddNormalizedTitleToGames < ActiveRecord::Migration[7.0]
  def up
    add_column :games, :normalized_title, :string
    add_index  :games, :normalized_title

    # 既存ゲームのバックフィル
    Game.find_each do |game|
      game.update_column(:normalized_title, Game.normalize_for_search(game.title.to_s))
    end
  end

  def down
    remove_column :games, :normalized_title
  end
end
