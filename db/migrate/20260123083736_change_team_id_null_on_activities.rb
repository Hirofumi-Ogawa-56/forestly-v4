# db/migrate/XXXXXXXXXXXXXX_change_team_id_null_on_activities.rb
class ChangeTeamIdNullOnActivities < ActiveRecord::Migration[7.2]
  def up
    # 1. 外部キーチェックを完全に無効化
    execute "PRAGMA foreign_keys = OFF"

    # 2. 現在のデータを一時テーブルに退避
    execute "CREATE TABLE activities_backup AS SELECT * FROM activities"

    # 3. 元のテーブルを削除
    drop_table :activities

    # 4. 理想的な構成（team_id が null 許可）でテーブルを再作成
    # ※ schema.rb の内容をベースに作成します
    create_table "activities", force: :cascade do |t|
      t.integer "owner_profile_id", null: false
      t.integer "team_id" # null: false を外しました
      t.string "title"
      t.integer "status"
      t.integer "visibility_range"
      t.string "actable_type", null: false
      t.integer "actable_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "chat_room_id"
      t.boolean "can_edit", default: false, null: false
      t.index [ "actable_type", "actable_id" ], name: "index_activities_on_actable"
      t.index [ "chat_room_id" ], name: "index_activities_on_chat_room_id"
      t.index [ "owner_profile_id" ], name: "index_activities_on_owner_profile_id"
      t.index [ "team_id" ], name: "index_activities_on_team_id"
    end

    # 5. データを書き戻す
    execute "INSERT INTO activities SELECT * FROM activities_backup"

    # 6. 一時テーブルを削除
    execute "DROP TABLE activities_backup"

    # 7. 外部キーチェックを戻す
    execute "PRAGMA foreign_keys = ON"
  end

  def down
    # 戻す必要がある場合は、逆の手順で null: false に戻す記述が必要ですが、
    # 今回は開発中につき上げっぱなしで問題ありません。
    raise ActiveRecord::IrreversibleMigration
  end
end
