class AddDetailFieldsToActivities < ActiveRecord::Migration[7.2]
  def change
    add_column :activities, :permission_type, :integer
    add_column :activities, :allow_comment, :boolean
    add_column :activities, :allow_reaction, :boolean
    add_column :activities, :log_access, :boolean
  end
end
