# app/models/activity.rb
class Activity < ApplicationRecord
  belongs_to :owner_profile, class_name: "Profile"
  belongs_to :team, optional: true
  belongs_to :actable, polymorphic: true, dependent: :destroy
  belongs_to :chat_room, optional: true
  belongs_to :task, foreign_key: :actable_id, optional: true
  belongs_to :schedule, foreign_key: :actable_id, optional: true
  belongs_to :parent_activity, class_name: "Activity", optional: true

  has_one :task_relation, -> { where(activities: { actable_type: "Task" }) },
          foreign_key: :id, primary_key: :actable_id, class_name: "Task"
  has_one :schedule_relation, -> { where(activities: { actable_type: "Schedule" }) },
          foreign_key: :id, primary_key: :actable_id, class_name: "Schedule"
  has_many :child_activities, class_name: "Activity", foreign_key: :parent_activity_id, dependent: :destroy

  # コメントといいねを簡単に取得するためのスコープ
  has_many :comment_activities, -> { where(actable_type: "Comment") },
           class_name: "Activity", foreign_key: :parent_activity_id
  has_many :like_activities, -> { where(actable_type: "Like") },
           class_name: "Activity", foreign_key: :parent_activity_id

  enum :status, { draft: 0, active: 1, archived: 2 }
  enum :visibility_range, { is_private: 0, is_team: 1, is_chat_room: 2, is_public: 3 }
  enum :permission_type, { read_only: 0, edit_only: 1 }

  validates :title, presence: true, unless: -> { actable_type.in?([ "Comment", "Like" ]) }

  scope :room_messages, -> { where(actable_type: "RoomMessage") }

  # 権限スコープ: 閲覧可能なレコードのみを絞り込む
  scope :visible_to, ->(profile) {
    return none unless profile

    # 自分が作成した、または公開されている、または所属チームに公開されている
    where(owner_profile: profile)
      .or(where(visibility_range: :is_public))
      .or(where(visibility_range: :is_team, team_id: profile.team_id).where.not(team_id: nil))
      .or(where(visibility_range: :is_chat_room, chat_room_id: profile.chat_rooms.select(:id)))
  }

  def editable_by?(profile)
    # 1. オーナーなら無条件でOK
    return true if owner_profile == profile

    # 2. 権限設定が「閲覧のみ(read_only)」ならNG
    return false if permission_type == "read_only"

    # 3. 公開範囲（visibility_range）のチェック
    case visibility_range
    when "is_team"
      owner_profile.team_id == profile.team_id
    when "is_chat_room"
      chat_room&.profiles&.include?(profile)
    else
      false
    end
  end

  # 単一のプロフィールに対して表示可能かを判定
  def visible_to?(profile)
    return false unless profile

    owner_profile == profile ||
    visibility_range == "is_public" ||
    (visibility_range == "is_team" && team_id == profile.team_id && team_id.present?) ||
    (visibility_range == "is_chat_room" && chat_room&.profiles&.include?(profile))
  end

  def comments_count
    comment_activities.count
  end

  def likes_count
    like_activities.count
  end
end
