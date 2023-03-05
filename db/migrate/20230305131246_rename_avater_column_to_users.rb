class RenameAvaterColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :avater, :avatar
  end
end
