# app/models/social_post.rb
class SocialPost < ApplicationRecord
  has_one :activity, as: :actable, dependent: :destroy
  has_many :reposts, class_name: "SocialRepost", foreign_key: "source_post_id"
  validates :content, presence: true, unless: -> { type == "SocialRepost" }

  delegate :status, :visibility_range, :owner_profile, :created_at, to: :activity, allow_nil: true
end
