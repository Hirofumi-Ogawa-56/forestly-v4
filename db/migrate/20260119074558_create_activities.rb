class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.references :owner_profile, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :title
      t.integer :status
      t.integer :visibility_range
      t.references :actable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
