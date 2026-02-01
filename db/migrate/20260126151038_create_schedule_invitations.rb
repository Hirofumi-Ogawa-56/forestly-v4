# db/migrate/xxxx_
class CreateScheduleInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :schedule_invitations do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true

      # invitation_status のデフォルトを 'pending' に
      t.string :invitation_status, default: 'pending', null: false

      # join_status のデフォルトを 'pending' に
      t.string :join_status, default: 'pending', null: false

      t.timestamps
    end

    # 同じ人を同じ予定に二重招待できないようにするユニーク制約
    add_index :schedule_invitations, [ :schedule_id, :profile_id ], unique: true
  end
end
