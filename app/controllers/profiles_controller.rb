# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :edit, :update, :destroy, :switch ]

  def switch
    # 1. セッションを切り替える
    session[:current_profile_id] = @profile.id

    # 2. 現在のURLを解析して、IDが含まれるパスなら置換してリダイレクト
    begin
      return redirect_to authenticated_root_path, status: :see_other if request.referer.nil?

      uri = URI.parse(request.referer)
      # Railsのルーターを使って現在のパスからパラメーターを抽出
      path_params = Rails.application.routes.recognize_path(uri.path)

      if path_params[:id].present?
        # URLにIDが含まれる場合(editなど)、新しいプロフィールのIDに差し替えてジャンプ
        path_params[:id] = @profile.id
        redirect_to url_for(path_params), notice: "#{@profile.name} に切り替えました"
      else
        # IDが含まれないページ（indexなど）ならそのまま戻る
        redirect_back(fallback_location: authenticated_root_path, notice: "#{@profile.name} に切り替えました", status: :see_other)
      end
    rescue => e
      # 解析不能なパスの場合は安全にルートへ
      redirect_to authenticated_root_path, notice: "#{@profile.name} に切り替えました", status: :see_other
    end
  end

  def index
    @profiles = current_user.profiles
  end

  def new
    @profile = current_user.profiles.build
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    if @profile.save
      redirect_to profiles_path, notice: "プロフィールを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      # 更新後、自身の編集画面へ戻る（整合性維持のため @profile を使用）
      redirect_to edit_profile_path(@profile), notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.profiles.count <= 1
      redirect_to edit_profile_path(@profile), alert: "最後のプロフィールは削除できません。"
      return
    end

    @profile.destroy

    # 削除したのが現在選択中のプロフィールなら、残った最初のプロフィールに切り替え
    if session[:current_profile_id].to_i == @profile.id
      session[:current_profile_id] = current_user.profiles.first.id
    end

    redirect_to authenticated_root_path, notice: "プロフィールを削除しました。"
  end

  private

  def set_profile
    # current_user.profiles を経由することで他人のプロフィールアクセスを防止
    @profile = current_user.profiles.find(params[:id])

    # 【重要】編集・更新アクション時、URLのIDが「選択中のID」と違う場合は強制リダイレクト
    if [ "edit", "update" ].include?(action_name)
      if @profile.id != current_profile.id
        # redirect_to の後に return がないと、この後のアクション処理も走ってしまいエラーになります
        redirect_to edit_profile_path(current_profile)
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to authenticated_root_path, alert: "プロフィールが見つかりません。"
  end

  def profile_params
    params.require(:profile).permit(:name, :label, :avatar)
  end
end
