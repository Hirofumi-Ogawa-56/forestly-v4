# app/models/chat_room.rb
class ChatRoom < ApplicationRecord
  has_many :room_memberships, dependent: :destroy
  has_many :profiles, through: :room_memberships
  has_many :activities, foreign_key: :chat_room_id
  has_one_attached :avatar

  enum :status, { active: 0, archived: 1 }

  attr_accessor :creator_profile_id
  after_create_commit :add_creator_as_admin

  def display_name
    super.presence || "無題のルーム"
  end

  private

  def add_creator_as_admin
    return if creator_profile_id.blank?

    room_memberships.create!(
      profile_id: creator_profile_id,
      role: :admin
    )
  end
end
