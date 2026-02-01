# spec/requests/likes_spec.rb
require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }
  # actableとしてRoomMessageを紐付ける
  let(:room_message) { create(:room_message) }
  let(:activity) { create(:activity, owner_profile: profile, title: "Test", actable: room_message) }

  before do
    sign_in user
    allow_any_instance_of(ApplicationController).to receive(:current_profile).and_return(profile)
  end

  describe "POST /activities/:activity_id/likes" do
    it "1回目のリクエストでLikeが作成されること" do
      expect {
        post activity_likes_path(activity)
      }.to change(Like, :count).by(1)
    end

    it "2回目のリクエストでLikeが削除されること（トグル機能）" do
      post activity_likes_path(activity)
      expect {
        post activity_likes_path(activity)
      }.to change(Like, :count).by(-1)
    end

    it "実行後に元のページにリダイレクトされること" do
      # HTTP_REFERERがない場合でもrootに飛ぶように調整
      post activity_likes_path(activity), headers: { "HTTP_REFERER" => authenticated_root_path }
      expect(response).to redirect_to(authenticated_root_path)
    end
  end
end
