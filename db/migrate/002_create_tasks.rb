class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :context
      t.string :status, default: 'planning', null: false

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, [:user_id, :status]
  end
end
