class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      # foreign_key: true を削除、または
      # もし profiles テーブルと紐付けたいなら以下の書き方に変更
      t.references :owner_profile, null: false, foreign_key: { to_table: :profiles }

      t.references :team, null: false, foreign_key: true
      t.string :title
      t.integer :status
      t.integer :visibility_range
      t.references :actable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
