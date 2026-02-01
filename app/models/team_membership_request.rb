class TeamMembershipRequest < ApplicationRecord
  belongs_to :team
  belongs_to :profile

  enum :status, { pending: 0, accepted: 1, rejected: 2, canceled: 3 }
  enum :role, { member: 0, admin: 1 }
end
