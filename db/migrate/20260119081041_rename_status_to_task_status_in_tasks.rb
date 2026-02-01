# db/migrate/xxxx_rename_status_to_task_status_in_tasks.rb
class RenameStatusToTaskStatusInTasks < ActiveRecord::Migration[7.1]
  def change
    rename_column :tasks, :status, :task_status
  end
end
