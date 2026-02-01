class ChangeTeamIdNullOnActivities < ActiveRecord::Migration[7.2]
  def up
    # team_id カラムの NOT NULL 制約を外す（nullを許可する）
    change_column_null :activities, :team_id, true
  end

  def down
    # 戻すときは false に（データにnullがあるとエラーになるので注意）
    change_column_null :activities, :team_id, false
  end
end