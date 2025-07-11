class AddIsActiveToTenancy < ActiveRecord::Migration[8.0]
  def change
    add_column :tenancies, :is_active, :boolean, default: false, null: false
  end
end
