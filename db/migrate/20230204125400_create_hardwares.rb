class CreateHardwares < ActiveRecord::Migration[7.0]
  def change
    create_table :hardwares do |t|
      t.string :name
      t.timestamps
    end
  end
end
