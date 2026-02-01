class ChangeSchedulesColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :schedules, :schedule_at, :start_at
    add_column :schedules, :end_at, :datetime
  end
end
