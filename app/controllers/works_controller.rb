# app/controllers/works_controller.rb
class WorksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_work, only: [ :show, :edit, :update, :destroy ]

  def index
    @current_profile = current_profile
    # ActivityからWork型のものを取得し、権限で絞り込む
    query = Activity.where(actable_type: "Work").visible_to(@current_profile)

    # フィルタリング
    case params[:filter]
    when "mine"
      query = query.where(owner_profile: @current_profile)
    when "shared"
      query = query.where.not(owner_profile: @current_profile)
    end

    @activities = query.includes(:owner_profile, actable: :actable).order(updated_at: :desc)
  end

  def new
    @work = Work.new
    @work.build_activity(owner_profile: current_profile, visibility_range: :is_private)
    @note = Note.new
  end

  def create
    @work = Work.new(work_params)
    @note = Note.new(note_params) # note_paramsを使用

    @work.actable = @note
    @work.activity.owner_profile = current_profile
    @work.activity.team = current_profile.team

    if @work.save
      redirect_to works_path, notice: "ドキュメントを作成しました"
    else
      # エラー時はnewの状態に戻す
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @activity = @work.activity
    @note = @work.actable
    unless @activity.editable_by?(current_profile)
      redirect_to works_path, alert: "編集権限がありません"
    end
  end

  def update
    @note = @work.actable
    # Work(Activity含む)とNoteの両方を更新
    if @work.update(work_params) && @note.update(note_params)
      redirect_to works_path, notice: "ドキュメントを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @activity = @work.activity
    @note = @work.actable

    # 閲覧権限チェック
    redirect_to works_path, alert: "アクセス権限がありません" unless @activity.visible_to?(current_profile)
  end

  def destroy
    # オーナーのみ削除可能
    if @work.activity.owner_profile == current_profile
      @work.destroy
      redirect_to works_path, notice: "ドキュメントを削除しました"
    else
      redirect_to works_path, alert: "削除権限がありません"
    end
  end

  private

  def set_work
    @work = Work.find(params[:id])
  end

  def work_params
    params.require(:work).permit(
      activity_attributes: [ :id, :title, :visibility_range, :chat_room_id, :permission_type, :allow_comment, :allow_reaction ]
    )
  end

  def note_params
    params.require(:note).permit(:content)
  end
end
