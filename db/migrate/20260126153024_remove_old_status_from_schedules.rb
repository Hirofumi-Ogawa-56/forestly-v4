# db/migrate/xxxx_remove_old_status_from_schedules.rb
class RemoveOldStatusFromSchedules < ActiveRecord::Migration[7.2]
  def change
    # 不要になった本体側のカラムを削除します
    remove_column :schedules, :invitation_status, :integer
    remove_column :schedules, :join_status, :integer
  end
end
