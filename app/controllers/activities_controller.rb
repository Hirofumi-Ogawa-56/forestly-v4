# app/controllers/activities_controller.rb
class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @activity = Activity.find(params[:id])

    # セキュリティ：作成者本人のみ削除可能
    if @activity.owner_profile == current_profile
      # activityを消せば、関連する task や schedule も dependent: :destroy で消えます
      @activity.destroy
      redirect_to tasks_path, notice: "削除しました", status: :see_other
    else
      redirect_to tasks_path, alert: "削除する権限がありません", status: :forbidden
    end
  end
end
