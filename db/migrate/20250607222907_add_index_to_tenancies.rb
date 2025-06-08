class AddIndexToTenancies < ActiveRecord::Migration[8.0]
  def change
    add_index :tenancies, [:room_id, :start_date, :end_date]
    add_index :tenancies, [:user_id, :start_date, :end_date]
  end
end
