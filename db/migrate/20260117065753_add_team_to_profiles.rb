class AddTeamToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_reference :profiles, :team, foreign_key: true
    add_column :profiles, :team_role, :integer # 0: member, 1: admin
    add_column :profiles, :profile_id, :string # 招待時に検索で使うID
    add_index :profiles, :profile_id, unique: true
  end
end
