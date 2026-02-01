class AddStatusAndTeamFieldsToProfiles < ActiveRecord::Migration[7.2]
  def change
    # status 0: active, 1: archived
    add_column :profiles, :status, :integer, default: 0, null: false

    # すでにマイグレーション済みであればこれ以降は不要ですが、
    # エラーが出ている場合は以下のカラムも不足している可能性があります
    unless column_exists?(:profiles, :team_role)
      add_column :profiles, :team_role, :integer
    end

    unless column_exists?(:profiles, :profile_id)
      add_column :profiles, :profile_id, :string
      add_index :profiles, :profile_id, unique: true
    end
  end
end
