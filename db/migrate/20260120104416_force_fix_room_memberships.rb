# db/migrate/xxxx_force_fix_room_memberships.rb
class ForceFixRoomMemberships < ActiveRecord::Migration[7.2]
  def change
    # 古いテーブルがあれば削除
    if table_exists?(:chat_memberships)
      drop_table :chat_memberships, force: :cascade
    end

    # 新しい名前で確実に作成
    create_table :room_memberships do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true
      t.integer :role
      t.timestamps
    end
  end
end
