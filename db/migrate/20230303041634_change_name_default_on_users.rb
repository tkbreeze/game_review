class ChangeNameDefaultOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :name, from: "", to:"名無し"
  end
end
