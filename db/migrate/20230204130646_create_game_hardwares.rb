class CreateGameHardwares < ActiveRecord::Migration[7.0]
  def change
    create_table :game_hardwares do |t|
      t.references :game, null: false, foreign_key: true
      t.references :hardware, null: false, foreign_key: true

      t.timestamps
    end
  end
end
