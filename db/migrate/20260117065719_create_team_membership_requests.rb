class CreateTeamMembershipRequests < ActiveRecord::Migration[7.2]
  def change
      create_table :team_membership_requests do |t|
      t.references :team, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.integer :status, default: 0 # 0: pending, 1: accepted, 2: rejected, 3: canceled
      t.timestamps
    end
  end
end
