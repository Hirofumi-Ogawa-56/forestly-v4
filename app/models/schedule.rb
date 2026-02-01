# app/models/schedule.rb
class Schedule < ApplicationRecord
  # Activityとのポリモーフィック関連
  has_one :activity, as: :actable, dependent: :destroy
  accepts_nested_attributes_for :activity

  # 招待ユーザー（複数）との紐付け
  has_many :schedule_invitations, dependent: :destroy
  has_many :invitees, through: :schedule_invitations, source: :profile

  # ステータスの定義（設計通り）
  enum :schedule_status, {
    confirmed: "confirmed",
    suggestion: "suggestion",
    canceled: "canceled"
  }, default: :confirmed, prefix: true
end
