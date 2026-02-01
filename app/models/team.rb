class Team < ApplicationRecord
  has_many :profiles
  has_many :team_membership_requests, dependent: :destroy
  has_one_attached :avatar

  enum :status, { active: 0, archived: 1 }

  validates :display_name, presence: true

  # ステータスが archived に更新されたら所属メンバーを解放する
  after_update :release_members, if: :saved_change_to_archived?

  private

  def saved_change_to_archived?
    saved_change_to_status? && archived?
  end

  def release_members
    # 所属している全プロフィールの team_id と role をリセット
    profiles.update_all(team_id: nil, team_role: nil)
  end
end
