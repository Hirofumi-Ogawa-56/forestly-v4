# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  # GET /resource/sign_up
  def new
    build_resource({})
    # ここでProfileを1つビルドしておくことで、ビューのfields_forが反応する
    resource.profiles.build
    respond_with resource
  end

  # POST /resource
  def create
    super
    # 必要に応じて保存後の追加ロジックをここに書けます
  end
end
