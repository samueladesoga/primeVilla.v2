class RemoveIsEmptyFromRoom < ActiveRecord::Migration[8.0]
  def change
    remove_column :rooms, :is_empty, :boolean
  end
end
