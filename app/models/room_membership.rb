# app/models/room_mrmbership.rb
class RoomMembership < ApplicationRecord
  belongs_to :profile
  belongs_to :chat_room
  enum :role, { member: 0, admin: 1 }
end
