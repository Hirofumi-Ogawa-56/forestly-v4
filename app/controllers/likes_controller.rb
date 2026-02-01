# app/controllers/likes_controller.rb
class LikesController < ApplicationController
  before_action :set_activity

  def create
    # すでにいいねしているか確認
    existing_like_activity = @activity.like_activities.find_by(owner_profile: current_profile)

    if existing_like_activity
      # すでに存在すれば削除（トグル）
      existing_like_activity.destroy
      msg = "いいねを取り消しました"
    else
      # なければ作成
      like = Like.new
      @activity.child_activities.create!(
        actable: like,
        owner_profile: current_profile,
        visibility_range: @activity.visibility_range,
        team_id: @activity.team_id,
        chat_room_id: @activity.chat_room_id,
        status: :active
      )
      msg = "いいねしました"
    end

    redirect_back fallback_location: root_path, notice: msg
  end

  private

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end
end
