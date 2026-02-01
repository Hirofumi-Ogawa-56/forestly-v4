# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_profile

  def current_profile
    return @current_profile if @current_profile

    # 1. セッションに保存されたIDがあるか確認
    # 2. なければ最新のプロフィールを使用
    # 3. それもなければ nil
    if session[:current_profile_id]
      @current_profile = current_user.profiles.find_by(id: session[:current_profile_id])
    end

    @current_profile ||= current_user.profiles.first
  end

  protected

  # ログイン後に遷移するパスを指定
  def after_sign_in_path_for(resource)
    tasks_path
  end

  def configure_permitted_parameters
    # サインアップ時にprofiles_attributesを許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [ profiles_attributes: [ :label, :name, :avatar ] ])
  end
end
