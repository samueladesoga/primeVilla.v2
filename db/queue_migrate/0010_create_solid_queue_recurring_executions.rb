class CreateSolidQueueRecurringExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_recurring_executions do |t|
      t.bigint :job_id, null: false
      t.string :task_key, null: false
      t.datetime :run_at, null: false
      t.datetime :created_at, null: false
    end

    add_index :solid_queue_recurring_executions, [:job_id], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    add_index :solid_queue_recurring_executions, [:task_key, :run_at], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end
end