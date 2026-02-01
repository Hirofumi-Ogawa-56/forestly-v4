class CreateSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :schedules do |t|
      t.datetime :schedule_at
      t.text :describe
      t.integer :invitation_status
      t.integer :join_status

      t.timestamps
    end
  end
end
