class CreateChatMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_memberships do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true
      t.integer :role

      t.timestamps
    end
  end
end
