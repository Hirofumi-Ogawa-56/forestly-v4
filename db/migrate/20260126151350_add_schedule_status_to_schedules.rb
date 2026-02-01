# db/migrate/xxxx_add_schedule_status_to_schedules.rb
class AddScheduleStatusToSchedules < ActiveRecord::Migration[7.2]
  def change
    add_column :schedules, :schedule_status, :string, default: 'confirmed', null: false
  end
end
