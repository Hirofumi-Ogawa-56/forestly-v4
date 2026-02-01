class AddParentActivityToActivities < ActiveRecord::Migration[7.2]
  def change
    add_column :activities, :parent_activity_id, :integer
    add_index :activities, :parent_activity_id
  end
end
