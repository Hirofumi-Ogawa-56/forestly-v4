class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :display_name, null: false
      t.integer :status, default: 0 # 0: active, 1: archived
      t.timestamps
    end
  end
end
