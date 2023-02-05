class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.date :release_date
      t.string :maker
      t.string :title
      t.timestamps
    end
  end
end
