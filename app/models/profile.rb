# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true # 所属しないプロフィールもあるため
  has_many :team_membership_requests, dependent: :destroy
  has_many :room_memberships, class_name: "RoomMembership", dependent: :destroy
  has_many :chat_rooms, through: :room_memberships, source: :chat_room
  has_many :activities, foreign_key: :owner_profile_id, dependent: :destroy
  has_many :task_assignees, dependent: :destroy
  has_one_attached :avatar

  # 概要に基づいたステータスとロール
  enum :status, { active: 0, archived: 1 }
  enum :team_role, { member: 0, admin: 1 }

  validates :label, :name, presence: true
  validates :profile_id, uniqueness: { allow_nil: true }

  before_validation :generate_profile_id

  # 招待を受け取っているリクエスト
  def pending_requests
    team_membership_requests.where(status: :pending)
  end

  private

  def generate_profile_id
    return if profile_id.present?
    # ランダムな英数字8桁（重複があれば再生成）
    self.profile_id ||= loop do
      random_id = SecureRandom.alphanumeric(8).downcase
      break random_id unless Profile.exists?(profile_id: random_id)
    end
  end
end
