# db/migrate/xxxx_create_tasks.rb
class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.integer :status, default: 0
      t.datetime :deadline
      t.text :content

      t.timestamps
    end
  end
end
