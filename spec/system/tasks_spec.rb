# spec/system/tasks_spec.rb
require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }

  before do
    sign_in user
    # current_profileをスタブ化して、チームがない状態でも動くようにする
    allow_any_instance_of(ApplicationController).to receive(:current_profile).and_return(profile)
  end

  it "新しいタスクを正常に作成でき、不要な設定項目が表示されていないこと" do
    visit authenticated_root_path

    # ボタンを探してクリック（JSで制御されている場合を考慮）
    click_on "新規タスク"

    # 1. MVPで削除した項目（以前のフォームにあったもの）が表示されていない確認
    expect(page).not_to have_content "コメントを許可"
    expect(page).not_to have_content "リアクションを許可"

    # 2. フォームへの入力
    # placeholder を使ってタイトルを入力
    fill_in "タスク名を入力...", with: "MVPタスク"

    # describe（説明欄）を入力
    fill_in "task[describe]", with: "これはテストです"

    # 3. 保存ボタンをクリック（文言を「タスクを保存」に修正）
    click_on "タスクを保存"

    # 4. 完了後の確認
    expect(page).to have_content "MVPタスク"

    # DB側でも確認
    expect(Activity.last.title).to eq "MVPタスク"
  end
end
