class AddAvaterToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :avater, :string
  end
end
