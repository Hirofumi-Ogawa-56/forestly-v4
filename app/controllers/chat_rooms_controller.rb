# app/controllers/chat_rooms_controller.rb
class ChatRoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    # メインコンテンツは空（またはルーム選択を促すメッセージ）
  end

  def new
    @chat_room = ChatRoom.new
  end

  def create
    @chat_room = ChatRoom.new(chat_room_params)
    # ログイン中のプロフィールIDを作成者として渡す
    @chat_room.creator_profile_id = current_profile.id

    if @chat_room.save
      redirect_to chat_rooms_path, notice: "チャットルームを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @chat_room = ChatRoom.find(params[:id])
  end

  def update
    @chat_room = ChatRoom.find(params[:id])
    if @chat_room.update(chat_room_params)
      # 保存後に edit ページへリダイレクト（＝リロード）
      # notice に入れた文言がアラートとして表示される
      redirect_to edit_chat_room_path(@chat_room), notice: "ルーム設定を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    # 1. 「現在選択中のプロフィール」が参加しているルームの中から探す
    # RecordNotFound を防ぐため、find ではなく find_by を使います
    @chat_room = current_profile.chat_rooms.find_by(id: params[:id])

    # 2. もし見つからなかったら（参加していないルームなら）
    if @chat_room.nil?
      redirect_to chat_rooms_path, notice: "そのチャットルームには参加していないか、存在しません。"
    end

    # 見つかった場合はそのまま show.html.erb がレンダリングされます
  end


  def chat_room_params
    params.require(:chat_room).permit(:display_name, :avatar)
  end
end
