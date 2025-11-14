class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.integer :xp, default: 0, null: false
      t.integer :level, default: 1, null: false
      t.text :narrator_prompt

      t.timestamps
    end

    add_index :users, :username, unique: true
  end
end
