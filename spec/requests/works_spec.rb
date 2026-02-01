# spec/requests/works_spec.rb
require 'rails_helper'

RSpec.describe "Works", type: :request do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user) }

  before do
    # Deviseのログインヘルパーを使い、ログイン状態にする
    sign_in user
    # アプリの仕様上、current_profile を切り替える必要がある場合はここに処理を書きます
    # 一旦、シンプルにログインのみで進めます
  end

  describe "GET /works" do
    it "正常にレスポンスを返すこと" do
      get works_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /works/:id" do
    let(:work_activity) { create(:activity, :with_work, owner_profile: profile) }

    it "自分の作成したWorkは表示できること" do
      get work_path(work_activity.actable) # ActivityのactableがWork
      expect(response).to have_http_status(:success)
      expect(response.body).to include(work_activity.title)
    end

    it "他人の非公開Workにアクセスするとリダイレクト（またはエラー）になること" do
      other_activity = create(:activity, :with_work, visibility_range: :is_private)

      # 現状のコントローラーの実装に合わせて検証
      # もし権限エラーでリダイレクトするように作っているなら:
      get work_path(other_activity.actable)
      expect(response).to redirect_to(works_path)
    end
  end
end
