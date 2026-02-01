# app/models/social_repost.rb
class SocialRepost < SocialPost
  # 元の投稿へのリレーション
  belongs_to :source_post, class_name: "SocialPost", foreign_key: "source_post_id"

  # リポストなので、元ネタ（source_post_id）は必須
  validates :source_post_id, presence: true
end
