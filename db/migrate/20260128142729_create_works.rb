class CreateWorks < ActiveRecord::Migration[7.2]
  def change
    create_table :works do |t|
      t.references :actable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
