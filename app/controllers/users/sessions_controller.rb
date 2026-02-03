# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  def guest_sign_in
    ActiveRecord::Base.transaction do
      # 1. 古いゲストユーザーの削除
      if old_user = User.find_by(email: "guest@example.com")
        old_user.profiles.destroy_all
        old_user.destroy
      end

      # 2. NPCのデモ投稿を一斉清掃（重複防止）
      npc_ids = [
        "tanaka_mgr", "takahashi_dev", "watanabe_des",
        "kenji_camp", "yuka_cook", "takuya_gear",
        "kobayashi_sensei", "sasaki_cook", "ito_cook"
      ]
      npc_profiles = Profile.where(profile_id: npc_ids)
      Activity.where(owner_profile: npc_profiles).destroy_all

      # 3. 新規ゲストユーザー作成
      user = User.find_or_create_by!(email: "guest@example.com") do |u|
        u.password = SecureRandom.urlsafe_base64
      end

      # --- Work (本業) ---
      p1 = user.profiles.create!(
        label: "Work (本業)",
        name: "Sato | Director",
        profile_id: "sato_work_#{SecureRandom.hex(3)}",
        status: 0,
      )
      # ローカルアセットからアタッチ
      attach_avatar_from_asset(p1, "avatar_work.png")

      p1.update(team: Team.find_by(display_name: "株式会社Forestly"))

      [ "全社連絡", "開発部", "雑談" ].each do |name|
        if room = ChatRoom.find_by(display_name: name)
          p1.room_memberships.create!(chat_room: room)
        end
      end

      tanaka = Profile.find_by(profile_id: "tanaka_mgr")
      takahashi = Profile.find_by(profile_id: "takahashi_dev")
      watanabe = Profile.find_by(profile_id: "watanabe_des")
      work_team = p1.team

      if tanaka && work_team
        post1 = SocialPost.create!(content: "【至急】本日17時からリリース判定会議を行います。各担当者は進捗を更新しておいてください！")
        Activity.create!(owner_profile: tanaka, team: work_team, title: "緊急ミーティングのお知らせ", actable: post1, visibility_range: :is_team, status: :active)

        if dev_room = ChatRoom.find_by(display_name: "開発部")
          m1 = RoomMessage.create!(content: "メイン機能のバグ修正完了しました。これより最終テストに入ります。")
          Activity.create!(owner_profile: takahashi, team: work_team, title: "バグ修正完了", actable: m1, chat_room_id: dev_room.id, visibility_range: :is_chat_room, status: :active)
          m2 = RoomMessage.create!(content: "テストサーバーが少し重いようです。インフラ担当の方、確認できますか？")
          Activity.create!(owner_profile: takahashi, team: work_team, title: "サーバー負荷報告", actable: m2, chat_room_id: dev_room.id, visibility_range: :is_chat_room, status: :active)
        end

        post2 = SocialPost.create!(content: "最終版のアイコンセットをWikiにアップしました！エンジニアの皆さん、確認お願いします✨")
        Activity.create!(owner_profile: watanabe, team: work_team, title: "デザインアセット更新", actable: post2, visibility_range: :is_team, status: :active) if watanabe

        task1 = Task.create!(describe: "リリース告知用バナーの最終チェック", task_status: 1, deadline: Time.now.end_of_day)
        Activity.create!(owner_profile: tanaka, team: work_team, title: "【緊急】バナー確認", actable: task1, visibility_range: :is_team, status: :active)
        TaskAssignee.create!(task: task1, profile: p1)

        task2 = Task.create!(describe: "顧客向けマニュアルの最終校正", task_status: 0, deadline: 1.day.from_now)
        Activity.create!(owner_profile: tanaka, team: work_team, title: "マニュアルチェック依頼", actable: task2, visibility_range: :is_team, status: :active)
        TaskAssignee.create!(task: task2, profile: p1)

        if chat_room = ChatRoom.find_by(display_name: "雑談")
          m3 = RoomMessage.create!(content: "今日のランチ、誰か一緒にどうですか？カレーの気分です🍛")
          Activity.create!(owner_profile: watanabe, team: work_team, title: "ランチのお誘い", actable: m3, chat_room_id: chat_room.id, visibility_range: :is_chat_room, status: :active)
        end
      end

      # --- Private (個人用) ---
      p2 = user.profiles.create!(
        label: "Private (個人用)",
        name: "Satomi",
        profile_id: "satomi_private_#{SecureRandom.hex(3)}",
        status: 0
      )
      # ローカルアセットからアタッチ
      attach_avatar_from_asset(p2, "avatar_private.png")

      [ "週末キャンプ会", "焚き火好き集まれ" ].each do |name|
        if room = ChatRoom.find_by(display_name: name)
          p2.room_memberships.create!(chat_room: room)
        end
      end

      kenji = Profile.find_by(profile_id: "kenji_camp")
      yuka = Profile.find_by(profile_id: "yuka_cook")
      takuya = Profile.find_by(profile_id: "takuya_gear")

      if kenji && yuka && takuya
        if camp_room = ChatRoom.find_by(display_name: "週末キャンプ会")
          m_p1 = RoomMessage.create!(content: "今週末、予報だと少し冷え込みそうですね。薪を多めに用意したほうがいいかも。")
          Activity.create!(owner_profile: kenji, title: "寒さ対策について", actable: m_p1, chat_room_id: camp_room.id, visibility_range: :is_chat_room, status: :active)
        end
        post_y = SocialPost.create!(content: "今回のキャンプ飯、ダッチオーブンでローストチキンに挑戦しようと思ってます！楽しみ🍗")
        Activity.create!(owner_profile: yuka, title: "メニュー決定！", actable: post_y, visibility_range: :is_public, status: :active)
        post_t = SocialPost.create!(content: "念願のオイルランタンを購入！今夜は家で灯してニヤニヤしてます。")
        Activity.create!(owner_profile: takuya, title: "新しいギア", actable: post_t, visibility_range: :is_public, status: :active)
        task_p1 = Task.create!(describe: "キャンプ場のチェックイン時間の確認と共有", task_status: 1, deadline: 1.day.from_now)
        Activity.create!(owner_profile: kenji, title: "【緊急】予約詳細確認", actable: task_p1, visibility_range: :is_team, status: :active)
        TaskAssignee.create!(task: task_p1, profile: p2)
        task_p3 = Task.create!(describe: "当日の朝、地元の野菜直売所に寄る", task_status: 0, deadline: 3.days.from_now)
        Activity.create!(owner_profile: yuka, title: "野菜の調達", actable: task_p3, visibility_range: :is_team, status: :active)
        TaskAssignee.create!(task: task_p3, profile: p2)
        note_p = Note.create!(body: "■キャンプスケジュール\n09:00 集合・出発\n13:00 チェックイン")
        work_p = Work.create!(actable: note_p)
        Activity.create!(owner_profile: p2, title: "週末キャンプのしおり", actable: work_p, visibility_range: :is_private, status: :active)
      end

      # --- School (料理教室) ---
      p3 = user.profiles.create!(
        label: "School (料理教室)",
        name: "Satomi @ Cooking",
        profile_id: "satomi_cook_#{SecureRandom.hex(3)}",
        status: 0
      )
      # ローカルアセットからアタッチ
      attach_avatar_from_asset(p3, "avatar_school.png")

      p3.update(team: Team.find_by(display_name: "ABCクッキング"))

      [ "3月生クラス", "レシピ共有" ].each do |name|
        if room = ChatRoom.find_by(display_name: name)
          p3.room_memberships.create!(chat_room: room)
        end
      end

      kobayashi = Profile.find_by(profile_id: "kobayashi_sensei")
      sasaki = Profile.find_by(profile_id: "sasaki_cook")
      ito = Profile.find_by(profile_id: "ito_cook")
      school_team = p3.team

      if kobayashi && sasaki && ito && school_team
        if school_room = ChatRoom.find_by(display_name: "3月生クラス")
          m_s1 = RoomMessage.create!(content: "次回の持ち寄りパーティー、皆さんの得意料理を楽しみにしていますね。")
          Activity.create!(owner_profile: kobayashi, team: school_team, title: "パーティーの注意事項", actable: m_s1, chat_room_id: school_room.id, visibility_range: :is_chat_room, status: :active)
        end
        post_s = SocialPost.create!(content: "昨日の復習で「肉じゃが」作りました！隠し味に白だしを入れると◎")
        Activity.create!(owner_profile: sasaki, team: school_team, title: "復習レポ", actable: post_s, visibility_range: :is_team, status: :active)
        task_s1 = Task.create!(describe: "パーティー会場の備品（紙皿・コップ）の在庫確認", task_status: 0, deadline: 3.days.from_now)
        Activity.create!(owner_profile: kobayashi, team: school_team, title: "備品チェック依頼", actable: task_s1, visibility_range: :is_team, status: :active)
        TaskAssignee.create!(task: task_s1, profile: p3)
        note_s = Note.create!(body: "■小林先生直伝・万能タレレシピ\n醤油3、みりん2...")
        work_s = Work.create!(actable: note_s)
        Activity.create!(owner_profile: p3, team: school_team, title: "料理教室メモ：万能タレ", actable: work_s, visibility_range: :is_private, status: :active)
      end

      # 4. サインイン処理
      guest_profile = user.profiles.find_by(label: "Work (本業)")
      session[:current_profile_id] = guest_profile.id
      sign_in user
    end # Transaction終了

    redirect_to root_path, notice: "guest_mode"
  rescue => e
    logger.error "Guest Sign In Error: #{e.message}"
    redirect_to new_user_session_path, alert: "エラーが発生しました。#{e.message}"
  end

  private

  # 外部URLではなくアセットフォルダから読み込むように変更
  def attach_avatar_from_asset(profile, filename)
    file_path = Rails.root.join("app/assets/images", filename)
    if File.exist?(file_path)
      profile.avatar.attach(
        io: File.open(file_path),
        filename: filename,
        content_type: "image/png"
      )
    else
      logger.error "Asset file not found: #{file_path}"
    end
  end
end
