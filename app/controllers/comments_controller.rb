# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_activity

  def create
    # contentの取得元をフォームの構造に合わせて調整（もし social_post[content] で送っているならそのままでOK）
    content = params.dig(:social_post, :content) || params.dig(:comment, :content)

    @comment = Comment.new(
        content: content,
        parent_id: params.dig(:comment, :parent_id).presence
    )

    if @comment.save
        Activity.create!(
        actable: @comment,
        owner_profile: current_profile,
        parent_activity_id: @activity.id,
        visibility_range: @activity.visibility_range,
        team_id: @activity.team_id,
        status: "active",
        title: @comment.content.truncate(20)
        )

        # 遷移元が SocialPostの一覧か ChatRoom かを判別して thread_id を付与
        if request.referer&.include?("chat_rooms")
        redirect_to chat_room_path(@activity.chat_room, thread_id: @activity.id), notice: "返信しました"
        else
        # SocialPostの場合は filter も維持しつつ thread_id を渡す
        redirect_to social_posts_path(filter: params[:filter], thread_id: @activity.id), notice: "コメントを投稿しました"
        end
    else
        redirect_back fallback_location: root_path, alert: "失敗しました"
    end
    end

  def destroy
    # Activityを探して削除（紐づくCommentも一緒に消える設計ならActivityを消す）
    # もしCommentを消したいなら、Activityのactableを消す
    @comment_activity = Activity.find_by(id: params[:id], actable_type: "Comment")

    if @comment_activity&.owner_profile == current_profile
      @comment_activity.actable.destroy # 実体のCommentを削除
      @comment_activity.destroy         # 器のActivityを削除
      redirect_back fallback_location: root_path, notice: "削除しました"
    else
      redirect_back fallback_location: root_path, alert: "権限がありません"
    end
  end

  private

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end
end
