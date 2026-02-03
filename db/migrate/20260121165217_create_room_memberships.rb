class CreateRoomMemberships < ActiveRecord::Migration[7.2]
  def change
    # この1行を追加します！
    return if table_exists?(:room_memberships)

    create_table :room_memberships do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true
      t.integer :role, default: 0, null: false

      t.timestamps
    end
  end
end
