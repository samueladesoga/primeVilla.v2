class CreateTenancies < ActiveRecord::Migration[8.0]
  def change
    create_table :tenancies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.text :comments

      t.timestamps
    end
  end
end
