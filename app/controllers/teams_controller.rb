# app/controllers/teams_controller.rb
class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  before_action :ensure_admin, only: [ :edit, :update ]

  def members
    if @team
      @members = @team.profiles
      # 履歴用にすべての招待リクエストを、新しい順で取得（N+1防止のためプロフィールをincludes）
      @invitation_history = @team.team_membership_requests.includes(:profile).order(created_at: :desc)
    else
      @members = []
      @invitation_history = []
    end
  end

  def new
    @team_new = Team.new unless @team
  end

  def create
    @team_new = Team.new(team_params)

    if current_profile.team.present?
      redirect_to members_team_path, alert: "既にチームに所属しているため、作成できません。"
      return
    end

    # トランザクションで「全部成功」か「全部失敗（ロールバック）」を保証
    ActiveRecord::Base.transaction do
      # 1. チームを保存
      @team_new.save!

      # 2. 【重要】古い中途半端なリクエスト（ゴミデータ）があればこのタイミングで削除
      # これにより "Profile has already been taken" エラーを未然に防ぎます
      current_profile.team_membership_requests.destroy_all

      # 3. プロフィールをadminとして紐付け
      current_profile.update!(
        team: @team_new,
        team_role: :admin
      )

      # 全て成功した場合のみ確定してリダイレクト
      redirect_to members_team_path, notice: "チーム「#{@team_new.display_name}」を作成しました。"
    end

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Validation failed for #{e.record.class}: #{e.record.errors.inspect}"
    # バリデーション失敗時：具体的になぜ失敗したかをメッセージに表示
    # 失敗時はtransactionのおかげで、作成されたチームはDBから消去（ロールバック）されます
    flash.now[:alert] = "作成に失敗しました: #{e.record.class.name} - #{e.record.errors.full_messages.join(', ')}"
    render :new, status: :unprocessable_entity
  rescue => e
    flash.now[:alert] = "予期せぬエラーが発生しました: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def edit
    # 未所属でもページ自体は見せるが、編集対象がない状態
  end

  def update
    if @team.update(team_params)
        redirect_to members_team_path, notice: "チーム情報を更新しました。"
    else
        render :edit, status: :unprocessable_entity
    end
   end

  private

  def set_team
    @team = current_profile.team
  end

  def team_params
    params.require(:team).permit(:display_name, :avatar)
  end

  def ensure_admin
    unless current_profile.admin?
        redirect_to members_team_path, alert: "管理者権限が必要です。"
    end
  end
end
