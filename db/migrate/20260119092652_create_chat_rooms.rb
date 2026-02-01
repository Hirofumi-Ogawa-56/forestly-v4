class CreateChatRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_rooms do |t|
      t.string :display_name
      t.integer :status

      t.timestamps
    end
  end
end
