# app/controllers/schedule_invitations_controller.rb
class ScheduleInvitationsController < ApplicationController
  before_action :authenticate_user!

  def update
    @invitation = ScheduleInvitation.find(params[:id])

    # 自分の招待のみ更新可能
    if @invitation.profile == current_profile
      if @invitation.update(invitation_params)
        redirect_to tasks_path, notice: "回答を更新しました"
      else
        redirect_to tasks_path, alert: "更新に失敗しました"
      end
    end
  end

  private

  def invitation_params
    params.require(:schedule_invitation).permit(:join_status)
  end
end
