# app/controllers/room_memberships_controller.rb
class RoomMembershipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat_room = ChatRoom.find(params[:chat_room_id])
    # チーム機能と同様、文字列のprofile_idで検索
    @profile = Profile.find_by(profile_id: params[:profile_id].to_s.downcase)

    if @profile
      # すでにメンバーかチェック
      if @chat_room.profiles.include?(@profile)
        redirect_to edit_chat_room_path(@chat_room), alert: "既にメンバーです"
      else
        @chat_room.room_memberships.create!(profile: @profile, role: params[:role] || :member)
        redirect_to edit_chat_room_path(@chat_room), notice: "#{@profile.name}さんを追加しました"
      end
    else
      redirect_to edit_chat_room_path(@chat_room), alert: "指定されたプロフィールIDが見つかりません"
    end
  end

  def destroy
    @membership = RoomMembership.find(params[:id])
    @chat_room = @membership.chat_room
    @membership.destroy
    redirect_to edit_chat_room_path(@chat_room), notice: "メンバーを解除しました"
  end
end
