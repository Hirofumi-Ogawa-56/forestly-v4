# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  def guest_sign_in
    user = User.find_or_create_by!(email: "guest@example.com") do |u|
      u.password = SecureRandom.urlsafe_base64
    end

    unless user.profiles.exists?
      # 1. 仕事用 (Work)
      # profile_id は index が unique なので、ゲストごとに被らない工夫が必要
      p1 = user.profiles.create!(
        label: "Work (本業)",
        name: "Sato | Director",
        profile_id: "sato_work_#{SecureRandom.hex(3)}",
        status: 0,
      )
      attach_avatar_from_url(p1, "https://res.cloudinary.com/do5pu5yu6/image/upload/v1769949178/avatar_work_w03rhg.png")

      # 2. プライベート用 (Private)
      p2 = user.profiles.create!(
        label: "Private (個人用)",
        name: "Satomi",
        profile_id: "satomi_private_#{SecureRandom.hex(3)}",
        status: 0
      )
      attach_avatar_from_url(p2, "https://res.cloudinary.com/do5pu5yu6/image/upload/v1769949178/avatar_private_u147ut.png")

      # 3. 外部活動用 (School)
      p3 = user.profiles.create!(
        label: "School (料理教室)",
        name: "Satomi @ Cooking",
        profile_id: "satomi_cook_#{SecureRandom.hex(3)}",
        status: 0
      )
      attach_avatar_from_url(p3, "https://res.cloudinary.com/do5pu5yu6/image/upload/v1769949178/avatar_school_mhhxwn.png")
    end

    # 最初に表示するプロフィールを「Work」に設定
    guest_profile = user.profiles.find_by(label: "Work (本業)")
    session[:current_profile_id] = guest_profile.id

    sign_in user
    redirect_to root_path, notice: "guest_mode"
  end

  private

  def attach_avatar_from_url(profile, url)
    require "open-uri"
    file = URI.open(url)
    profile.avatar.attach(io: file, filename: "avatar_#{profile.label}.png")
  rescue => e
    logger.error "Failed to attach avatar: #{e.message}"
  end
end
