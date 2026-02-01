# app/models/room_message.rb
class RoomMessage < ApplicationRecord
  # Activityとの紐付け（実体側）
  has_one :activity, as: :actable, dependent: :destroy

  # バリデーション
  validates :content, presence: true
end
