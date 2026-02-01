# app/contollers/team_invitations_controller.rb
class TeamInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_team_admin, only: [ :create, :cancel ]

  def search
    @target_profile = Profile.find_by(profile_id: params[:profile_id])

    # 既存の create にあるバリデーション（チーム所属済みか等）を
    # ここでも行い、エラーならリダイレクトするロジックを共通化すると良いです
    if @target_profile.nil?
      redirect_to members_team_path, alert: "指定されたプロフィールIDが見つかりません。"
    end
  end

  def create
    @target_profile = Profile.find_by(profile_id: params[:profile_id]&.downcase)

    # 1. プロフィールが存在するか
    if @target_profile.nil?
        return redirect_to members_team_path, alert: "指定されたプロフィールIDが見つかりません。入力内容を確認してください。"
    end

    # 2. 自分自身ではないか
    if @target_profile == current_profile
        return redirect_to members_team_path, alert: "自分自身を招待することはできません。"
    end

    # 3. 既にチームに所属していないか
    if @target_profile.team.present?
        return redirect_to members_team_path, alert: "#{@target_profile.name} さんは既にチームに所属しています。"
    end

    # 4. 既に招待送信済み（承認待ち）ではないか
    existing_request = TeamMembershipRequest.find_by(
        team: current_profile.team,
        profile: @target_profile,
        status: :pending
    )
    if existing_request
        return redirect_to members_team_path, alert: "#{@target_profile.name} さんには既に招待を送信済みです。"
    end

    # 招待の作成
    request = TeamMembershipRequest.new(
        team: current_profile.team,
        profile: @target_profile,
        status: :pending,
        role: params[:role]
    )

    if request.save
        redirect_to members_team_path, notice: "#{@target_profile.name} さんに招待（#{request.role_i18n}権限）を送信しました。"
    else
        redirect_to members_team_path, alert: "招待の送信に失敗しました。"
    end
  end

  def cancel
    # 自分のチームが送った招待であることを保証して取得
    @invitation = current_profile.team.team_membership_requests.find(params[:id])

    if @invitation.pending?
      @invitation.canceled!
      redirect_to members_team_path, notice: "#{@invitation.profile.name} さんへの招待を取り消しました。"
    else
      redirect_to members_team_path, alert: "この招待は既に取り消されているか、承認済みのため変更できません。"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to members_team_path, alert: "招待データが見つかりませんでした。"
  end

  def accept
    @invitation = TeamMembershipRequest.find(params[:id])

    # 自分宛てかつ保留中であることを確認
    if @invitation.profile == current_profile && @invitation.pending?
      if current_profile.team.present?
        return redirect_to edit_profile_path(current_profile), alert: "既にチームに所属しているため、新しく参加することはできません。"
      end

      # トランザクションでステータス更新とプロフィール更新を同時に行う
      ActiveRecord::Base.transaction do
        @invitation.accepted!
        current_profile.update!(
          team: @invitation.team,
          team_role: @invitation.role # 招待時のrole(admin/member)を反映
        )
      end
      redirect_to members_team_path, notice: "チーム「#{@invitation.team.display_name}」に参加しました！"
    else
      redirect_to edit_profile_path(current_profile), alert: "不正なリクエストです。"
    end
  end

  def reject
    @invitation = TeamMembershipRequest.find(params[:id])
    if @invitation.profile == current_profile && @invitation.pending?
      @invitation.rejected!
      redirect_to edit_profile_path(current_profile), notice: "招待を辞退しました。"
    else
      redirect_to edit_profile_path(current_profile), alert: "不正なリクエストです。"
    end
  end

  private

  def ensure_team_admin
    unless current_profile.admin?
      redirect_to members_team_path, alert: "管理者権限が必要です。"
    end
  end
end
