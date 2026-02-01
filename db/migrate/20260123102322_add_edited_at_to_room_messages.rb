class AddEditedAtToRoomMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :room_messages, :edited_at, :datetime
  end
end
