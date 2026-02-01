class RenameContentToDescribeInTasks < ActiveRecord::Migration[7.2]
  def change
    # tasksテーブルの content を describe に変更
    rename_column :tasks, :content, :describe
  end
end
