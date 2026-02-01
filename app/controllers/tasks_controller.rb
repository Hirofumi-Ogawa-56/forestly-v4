# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_profile = current_profile

    # 1. 招待者・担当者を含めて一括取得（N+1対策）
    query = Activity.where(actable_type: [ "Task", "Schedule" ])
                    .visible_to(@current_profile)
                    .includes(
                      :owner_profile,
                      actable: [
                        :assignees,
                        { schedule_invitations: :profile }
                      ]
                    )
                    .order(created_at: :desc)

    # フィルタリングロジック（変更なし）
    case params[:filter]
    when "today"
      today = Time.current.all_day
      query = query.left_joins(:task_relation, :schedule_relation)
                .where(tasks: { deadline: today })
                .or(query.left_joins(:task_relation, :schedule_relation).where(schedules: { start_at: today }))
    when "week"
      this_week = Time.current.beginning_of_day..7.days.from_now.end_of_day
      query = query.left_joins(:task_relation, :schedule_relation)
                  .where(tasks: { deadline: this_week })
                  # ↓ ここを schedule_at から start_at に修正
                  .or(query.left_joins(:task_relation, :schedule_relation).where(schedules: { start_at: this_week }))
    when "todo"
      query = query.joins(:task_relation).where(tasks: { task_status: :todo })
    end

    @activities = query.order(created_at: :desc)

    # --- フォーム用オブジェクトの初期化 ---
    # Task: 23:30 デフォルト
    default_task_time = Time.current.change(hour: 23, min: 30)
    @task = Task.new(deadline: default_task_time).tap { |t|
      t.build_activity(owner_profile: @current_profile, visibility_range: :is_private, status: :active)
    }

    # Schedule: 1時間後の正時をデフォルトに（例: 今が10:15なら11:00）
    default_schedule_time = Time.current.since(1.hour).change(min: 0)
    base_time = Time.current.since(1.hour).change(min: 0)
    @schedule = Schedule.new(start_at: base_time, end_at: base_time.since(1.hour)).tap { |s|
      s.build_activity(owner_profile: @current_profile, visibility_range: :is_private, status: :active)
    }
  end

  def new
    @current_profile = current_profile
    default_time = Time.current.change(hour: 23, min: 30)

    @task = Task.new(deadline: default_time)
    @task.build_activity(owner_profile: @current_profile, visibility_range: :is_private, status: :active)
  end

  def create
    if params[:task].present?
      @obj = Task.new(task_params)
    elsif params[:schedule].present?
      @obj = Schedule.new(schedule_params)
      @obj.invitee_ids = (@obj.invitee_ids << current_profile.id).uniq
    end

    @obj.activity.owner_profile = current_profile
    @obj.activity.team = current_profile.team

    if @obj.save
      if @obj.is_a?(Schedule)
        @obj.schedule_invitations.find_by(profile: current_profile)&.join_status_approved!
      end

      redirect_to tasks_path, notice: "#{ @obj.is_a?(Task) ? 'タスク' : '予定' }を作成しました"
    else
      index
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to tasks_path, notice: "ステータスを更新しました"
    else
      redirect_to tasks_path, alert: "更新に失敗しました"
    end
  end

  def edit
    @task = Task.find(params[:id])
    redirect_to tasks_path unless @task.activity.owner_profile == current_profile
  end

  private

  def task_params
    params.require(:task).permit(
      :task_status, :deadline, :describe,
      assignee_ids: [],
      activity_attributes: [
        :id,
        :title, :visibility_range, :chat_room_id,
        :permission_type, :allow_comment, :allow_reaction, :status
      ]
    )
  end

  def schedule_params
    params.require(:schedule).permit(
      :start_at,
      :end_at,
      :describe,
      :schedule_status,
      invitee_ids: [],
      activity_attributes: [
        :id, :title, :visibility_range, :chat_room_id,
        :permission_type, :allow_comment, :allow_reaction, :status
      ]
    )
  end
end
