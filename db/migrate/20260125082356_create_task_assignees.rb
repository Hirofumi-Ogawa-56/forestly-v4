class CreateTaskAssignees < ActiveRecord::Migration[7.2]
  def change
    create_table :task_assignees do |t|
      t.references :task, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
