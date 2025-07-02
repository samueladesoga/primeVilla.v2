class CreateSolidQueuePauses < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false
      t.datetime :created_at, null: false
    end

    add_index :solid_queue_pauses, [:queue_name], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end
end