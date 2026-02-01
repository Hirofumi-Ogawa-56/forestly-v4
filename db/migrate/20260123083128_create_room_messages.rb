class CreateRoomMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :room_messages do |t|
      t.text :content

      t.timestamps
    end
  end
end
