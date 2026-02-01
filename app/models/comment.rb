# app/models/comment.rb
class Comment < ApplicationRecord
  # Activityとのポリモーフィック関連
  has_one :activity, as: :actable, dependent: :destroy

  # 自己参照: スレッド機能（2層まで）
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy

  validates :content, presence: true
  validate :thread_depth_limit

  private

  # 3層目を作らせないバリデーション
  def thread_depth_limit
    if parent.present? && parent.parent.present?
      errors.add(:base, "スレッドは2階層までです")
    end
  end
end
