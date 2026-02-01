# spec/models/activity_spec.rb
require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe "閲覧権限 (visible_to?)" do
    let(:owner) { create(:profile) }
    let(:other_user) { create(:profile) }

    # チーム用データ
    let(:team) { create(:team) } # Factoryを使うように変更
    let(:team_owner) { create(:profile, team: team) }
    let(:team_member) { create(:profile, team: team) }

    context "非公開(is_private)の場合" do
      let(:private_activity) { create(:activity, :with_work, owner_profile: owner, visibility_range: :is_private) }
      it "オーナー本人は閲覧できること" do
        expect(private_activity.visible_to?(owner)).to be_truthy
      end
      it "他人は閲覧できないこと" do
        expect(private_activity.visible_to?(other_user)).to be_falsey
      end
    end

    context "チーム公開(is_team)の場合" do
      let(:team_activity) { create(:activity, :with_work, owner_profile: team_owner, team: team, visibility_range: :is_team) }
      it "同じチームのメンバーは閲覧できること" do
        expect(team_activity.visible_to?(team_member)).to be_truthy
      end
      it "チーム外のユーザーは閲覧できないこと" do
        expect(team_activity.visible_to?(other_user)).to be_falsey
      end
    end

    context "ルーム公開(is_chat_room)の場合" do
      let(:chat_room) { ChatRoom.create!(display_name: "秘密の部屋") }
      let(:room_member) { create(:profile) }
      let(:room_activity) do
        create(:activity, :with_work,
               owner_profile: owner,
               chat_room: chat_room,
               visibility_range: :is_chat_room)
      end
      before { chat_room.room_memberships.create!(profile: room_member, role: :member) }

      it "ルームメンバーは閲覧できること" do
        expect(room_activity.visible_to?(room_member)).to be_truthy
      end
      it "ルーム外のユーザーは閲覧できないこと" do
        expect(room_activity.visible_to?(other_user)).to be_falsey
      end
    end
  end # <-- ここで visible_to? の describe を閉じる

  describe "ポリモーフィック関連の整合性" do # <-- 独立させる
    it "Taskに紐付いたActivityが正しく作成されること" do
      activity = create(:activity, :with_task)
      expect(activity.actable_type).to eq "Task"
      expect(activity.actable).to be_a(Task)
    end

    it "Scheduleに紐付いたActivityが正しく作成されること" do
      activity = create(:activity, :with_schedule)
      expect(activity.actable_type).to eq "Schedule"
      expect(activity.actable).to be_a(Schedule)
    end
  end
end
