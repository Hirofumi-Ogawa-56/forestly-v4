# app/controllers/room_messages_controller.rb
class RoomMessagesController < ApplicationController
  def create
    @chat_room = ChatRoom.find(params[:chat_room_id])
    @current_profile = current_profile
    target_status = params[:commit_type] == "draft" ? :draft : :active

    # --- 1. スレッドへの返信 (Comment作成) ---
    if params[:parent_activity_id].present? && target_status == :active
      @parent_activity = Activity.find(params[:parent_activity_id])
      @comment = Comment.new(content: params[:room_message][:content])

      if @comment.save
        # ChatのスレッドとしてActivityを作成
        Activity.create!(
          actable: @comment,
          owner_profile: @current_profile,
          parent_activity_id: @parent_activity.id, # ここで親メッセージと紐付け
          team_id: @parent_activity.team_id,
          status: "active",
          visibility_range: @parent_activity.visibility_range,
          title: @comment.content.truncate(20)
        )
      end
      return redirect_to chat_room_path(@chat_room, thread_id: params[:parent_activity_id])
    end

    # --- 2. 既存メッセージの編集・下書き更新 ---
    if params[:message_id].present?
      @message = RoomMessage.find(params[:message_id])
      @activity = Activity.find_by(actable: @message)

      if @activity && @activity.owner_profile == @current_profile
        update_params = { content: params[:room_message][:content] }
        update_params[:edited_at] = Time.current if target_status == :active && @activity.active?

        if @message.update(update_params)
          @activity.update(
            status: target_status,
            title: params[:room_message][:content].truncate(20)
          )
        end
      end

    # --- 3. 新規メッセージ作成 ---
    else
      @message = RoomMessage.new(content: params[:room_message][:content])
      if @message.save
        @chat_room.activities.create!(
          actable: @message,
          owner_profile: @current_profile,
          status: target_status,
          title: @message.content.truncate(20)
        )
      end
    end

    redirect_to chat_room_path(@chat_room)
  end

  def destroy
    @chat_room = ChatRoom.find(params[:chat_room_id])
    @message = RoomMessage.find(params[:id])

    # 自身のプロフィールに紐づく Activity を探す
    activity = Activity.find_by(actable: @message, owner_profile: current_profile)

    if activity
        # ActivityとRoomMessageの両方を削除
        # (Activity.rbに has_one :room_message, dependent: :destroy があれば activity.destroy だけでもOK)
        activity.destroy
        @message.destroy
        flash[:notice] = "下書きを削除しました"
    else
        flash[:alert] = "削除権限がありません"
    end

    redirect_to chat_room_path(@chat_room)
  end

  def thread
    @chat_room = ChatRoom.find(params[:chat_room_id])
    @parent_message = RoomMessage.find(params[:id])
    @parent_activity = Activity.find_by(actable: @parent_message)
    @comments = @parent_activity.comment_activities.includes(:owner_profile, :actable).order(created_at: :asc)

    # レイアウトを適用せず、パーシャル（または特定部分）だけを返す
    render partial: "thread"
  end

  private

  def room_message_params
    params.require(:room_message).permit(:content)
  end
end
