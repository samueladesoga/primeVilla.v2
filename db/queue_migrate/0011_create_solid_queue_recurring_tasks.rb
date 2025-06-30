class CreateSolidQueueRecurringTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_recurring_tasks do |t|
      t.string :key, null: false
      t.string :schedule, null: false
      t.string :command, limit: 2048
      t.string :class_name
      t.text :arguments
      t.string :queue_name
      t.integer :priority, default: 0
      t.boolean :static, default: true, null: false
      t.text :description
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :solid_queue_recurring_tasks, [:key], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    add_index :solid_queue_recurring_tasks, [:static], name: "index_solid_queue_recurring_tasks_on_static"
  end
end