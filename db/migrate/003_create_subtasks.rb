class CreateSubtasks < ActiveRecord::Migration[7.1]
  def change
    create_table :subtasks do |t|
      t.references :task, null: false, foreign_key: true
      t.string :title, null: false
      t.string :status, default: 'pending', null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :subtasks, [:task_id, :position]
    add_index :subtasks, :status
  end
end
