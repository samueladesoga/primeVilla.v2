class CreateSolidQueueSemaphores < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :solid_queue_semaphores, [:expires_at], name: "index_solid_queue_semaphores_on_expires_at"
    add_index :solid_queue_semaphores, [:key, :value], name: "index_solid_queue_semaphores_on_key_and_value"
    add_index :solid_queue_semaphores, [:key], name: "index_solid_queue_semaphores_on_key", unique: true
  end
end