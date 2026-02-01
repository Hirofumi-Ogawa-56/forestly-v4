class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :parent_id

      t.timestamps
    end
    add_index :comments, :parent_id
  end
end
