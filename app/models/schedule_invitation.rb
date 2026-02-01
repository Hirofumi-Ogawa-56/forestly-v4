# app/models/schedule_invitation.rb
class ScheduleInvitation < ApplicationRecord
  belongs_to :schedule
  belongs_to :profile

  # 招待の状態 (主催者側)
  enum :invitation_status, {
    pending: "pending",
    suggestion: "suggestion",
    confirmed: "confirmed",
    canceled: "canceled"
  }, default: :pending, prefix: true

  # 参加の回答 (招待された側)
  enum :join_status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected"
  }, default: :pending, prefix: true
end
