# db/seeds.rb
require "open-uri"

# --- 画像アタッチ用のヘルパーメソッド ---
def attach_avatar(profile, url)
  begin
    file = URI.open(url)
    profile.avatar.attach(io: file, filename: "avatar_#{profile.profile_id}.png")
    puts "Successfully attached avatar for #{profile.name}"
  rescue => e
    puts "Failed to attach avatar for #{profile.name}: #{e.message}"
  end
end


# --- 1. 土台（チームとルーム）の作成 ---
work_team = Team.find_or_create_by!(display_name: "株式会社Forestly")
school_team = Team.find_or_create_by!(display_name: "ABCクッキング")

room_all  = ChatRoom.find_or_create_by!(display_name: "全社連絡")
room_dev  = ChatRoom.find_or_create_by!(display_name: "開発部")
room_chat = ChatRoom.find_by(display_name: "雑談") || ChatRoom.create!(display_name: "雑談")
# その他のルーム
[ "週末キャンプ会", "焚き火好き集まれ", "3月生クラス", "レシピ共有" ].each do |name|
  ChatRoom.find_or_create_by!(display_name: name)
end

# --- 2. 相手役（NPC）ユーザーの作成 ---
npc_user = User.find_or_create_by!(email: "npc_staff@example.com") do |u|
  u.password = "password123"
end

# --- 3. 同僚プロフィールの作成とルーム所属 ---

# A. 田中マネージャー（全体を統括）
tanaka = npc_user.profiles.find_or_create_by!(profile_id: "tanaka_mgr") do |p|
  p.name = "田中 | Manager"
  p.label = "Work"
  p.team = work_team
end
[ room_all, room_chat ].each { |r| tanaka.room_memberships.find_or_create_by!(chat_room: r) }

# B. 高橋さん（現場のリーダー）
takahashi = npc_user.profiles.find_or_create_by!(profile_id: "takahashi_dev") do |p|
  p.name = "高橋 | Dev Leader"
  p.label = "Work"
  p.team = work_team
end
[ room_all, room_dev ].each { |r| takahashi.room_memberships.find_or_create_by!(chat_room: r) }

# C. 渡辺さん（明るいデザイナー）
watanabe = npc_user.profiles.find_or_create_by!(profile_id: "watanabe_des") do |p|
  p.name = "渡辺 | Designer"
  p.label = "Work"
  p.team = work_team
end
[ room_all, room_dev, room_chat ].each { |r| watanabe.room_memberships.find_or_create_by!(chat_room: r) }

# --- db/seeds.rb (プライベートNPC追加分) ---
# ケンジ：キャンプ隊長
kenji = npc_user.profiles.find_or_create_by!(profile_id: "kenji_camp") do |p|
  p.name = "ケンジ | Camp Leader"
  p.label = "Private"
end

# ユカ：料理担当
yuka = npc_user.profiles.find_or_create_by!(profile_id: "yuka_cook") do |p|
  p.name = "ユカ | Outdoor Chef"
  p.label = "Private"
end

# タクヤ：ギア担当
takuya = npc_user.profiles.find_or_create_by!(profile_id: "takuya_gear") do |p|
  p.name = "タクヤ | Gear Enthusiast"
  p.label = "Private"
end

# --- db/seeds.rb (料理教室NPC追加分) ---

# 小林先生：メイン講師
kobayashi = npc_user.profiles.find_or_create_by!(profile_id: "kobayashi_sensei") do |p|
  p.name = "小林先生 | ABC Cooking"
  p.label = "School"
  p.team = school_team
end

# 佐々木さん：クラスメート（しっかり者）
sasaki = npc_user.profiles.find_or_create_by!(profile_id: "sasaki_cook") do |p|
  p.name = "佐々木 | 3月生"
  p.label = "School"
  p.team = school_team
end

# 伊藤さん：クラスメート（初心者）
ito = npc_user.profiles.find_or_create_by!(profile_id: "ito_cook") do |p|
  p.name = "伊藤 | 3月生"
  p.label = "School"
  p.team = school_team
end

# 料理教室系ルームに全員所属
[ "3月生クラス", "レシピ共有" ].each do |name|
  if r = ChatRoom.find_by(display_name: name)
    [ kobayashi, sasaki, ito ].each { |npc| npc.room_memberships.find_or_create_by!(chat_room: r) }
  end
end
