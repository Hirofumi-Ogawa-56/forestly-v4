# app/controllers/social_posts_controller.rb
class SocialPostsController < ApplicationController
  def index
    @current_profile = current_profile
    @base_query = Activity.where(actable_type: "SocialPost")
                       .includes(:owner_profile, actable: :source_post)

    @no_team_scoped = params[:filter] == "team" && @current_profile.team_id.blank?

    @activities = case params[:filter]
    when "team"
                    if @current_profile.team_id.present?
                       @base_query.where(visibility_range: :is_team, team_id: @current_profile.team_id).active
                    else
                        Activity.none
                    end
    when "mine"
                    @base_query.where(owner_profile: @current_profile).active
    when "draft"
                    @base_query.where(owner_profile: @current_profile).draft
    else
                    @base_query.visible_to(@current_profile).active
    end.order(created_at: :asc)
  end

  def create
    @current_profile = current_profile
    target_status = params[:commit_type] == "draft" ? :draft : :active
    v_range = params[:visibility_range] || "is_public"

    if params[:post_id].present?
      # 【編集時】
      @post = SocialPost.find(params[:post_id])
      @activity = @post.activity
      if @activity.owner_profile == @current_profile
        # social_post_params を使用
        @post.update(social_post_params)
        @activity.update(status: target_status, visibility_range: v_range, title: @post.content.truncate(20))
      end
    else
      # 【新規作成時】
      @post = SocialPost.new(social_post_params)
      if @post.save
        @post.create_activity!(
          owner_profile: @current_profile,
          team_id: @current_profile.team_id,
          status: target_status,
          visibility_range: v_range,
          title: @post.content.truncate(20)
        )
      end
    end
    # 元のフィルターを維持してリダイレクト
    redirect_to social_posts_path(filter: params[:filter])
  end

  def destroy
    @post = SocialPost.find(params[:id])
    @activity = @post.activity
    if @activity.owner_profile == current_profile
      @activity.destroy
      @post.destroy
    end
    redirect_back(fallback_location: social_posts_path)
  end

  def repost
    source_post = SocialPost.find(params[:id])

    # 1. SocialRepostレコードを作成
    # 属性名は schema に合わせて source_post_id でも source_post でもOKですが
    # content の取得階層を修正します
    repost = SocialRepost.new(
        source_post: source_post,
        content: params.dig(:social_post, :content) # 階層を安全に取得
    )

    if repost.save
        # 2. Activityレコードを作成
        # title も保存しておかないと一覧で困ることがあります
        source_activity = source_post.activity

        repost.create_activity!(
          owner_profile: current_profile,
          status: :active,
          visibility_range: params[:visibility_range] || source_post.visibility_range,
          team_id: (params[:visibility_range] == "is_team" ? current_profile.team_id : nil),
          title: "Repost: #{source_post.content.truncate(10)}"
        )
        redirect_to social_posts_path, notice: "リポストしました"
    else
        # ここで失敗している場合、Railsのログ (log/development.log) にエラーが出ます
        logger.error repost.errors.full_messages
        redirect_to social_posts_path, alert: "リポストの保存に失敗しました: #{repost.errors.full_messages.join(', ')}"
    end
  end

  def thread
    @parent_post = SocialPost.find(params[:id])
    @parent_activity = Activity.find_by(actable: @parent_post)
    @comments = @parent_activity.comment_activities.includes(:owner_profile, :actable).order(created_at: :asc)

    render partial: "social_posts/thread"
  end

  private

  def social_post_params
    params.require(:social_post).permit(:content)
  end
end
