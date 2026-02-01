# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [ :edit, :update ]

  def create
    @schedule = Schedule.new(schedule_params)
    # 自分のIDを招待者に含める
    @schedule.invitee_ids = (@schedule.invitee_ids << current_profile.id).uniq

    @schedule.build_activity if @schedule.activity.nil?
    @schedule.activity.owner_profile = current_profile
    @schedule.activity.team = current_profile.team

    if @schedule.save
        @schedule.schedule_invitations.find_by(profile: current_profile)&.join_status_approved!
        redirect_to tasks_path, notice: "予定を作成しました"
    else
        # indexに戻るための準備（TasksControllerのindex相当の処理が必要な場合があります）
        redirect_to tasks_path, alert: "作成に失敗しました"
    end
  end

  def edit
    @current_profile = current_profile
    # 判定ロジックをモデルに任せる
    unless @schedule.activity.editable_by?(current_profile)
      redirect_to tasks_path, alert: "編集権限がありません。"
    end
  end

  def update
    if @schedule.update(schedule_params)
      # Turbo Frameにより、indexの該当行だけが更新されます
      redirect_to tasks_path, notice: "予定を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(
        :start_at,
        :end_at,
        :describe,
        :schedule_status,
        invitee_ids: [],
        activity_attributes: [
        :id,             # 編集には必須
        :title,          # タイトル更新に必要
        :visibility_range,
        :chat_room_id,
        :permission_type,
        :allow_comment,
        :allow_reaction
        ]
    )
    end
end
