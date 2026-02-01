class AddRoleToTeamMembershipRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :team_membership_requests, :role, :integer
  end
end
