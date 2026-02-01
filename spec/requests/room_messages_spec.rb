# spec/requests/room_messages_spec.rb
require 'rails_helper'

RSpec.describe "RoomMessages", type: :request do
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }
  let(:chat_room) { create(:chat_room) }
  let(:message) { create(:room_message) }
  let!(:activity) { create(:activity, actable: message, chat_room: chat_room) }

  before { sign_in user }

  describe "GET /chat_rooms/:chat_room_id/room_messages/:id/thread" do
    it "スレッド表示用のリクエストが成功すること" do
    # パスヘルパー名を修正
    get thread_chat_room_room_message_path(chat_room, message)
    expect(response).to have_http_status(:success)
    end
  end
end
