# db/migrate/xxxx_add_chat_room_and_access_control_to_activities.rb
class AddChatRoomAndAccessControlToActivities < ActiveRecord::Migration[7.1]
  def change
    # references ではなく カラム単体で追加することで SQLite のエラーを回避します
    add_column :activities, :chat_room_id, :integer
    add_index :activities, :chat_room_id

    # 編集権限フラグを追加
    add_column :activities, :can_edit, :boolean, default: false, null: false
  end
end
