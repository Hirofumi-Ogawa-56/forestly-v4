# db/migrate/xxxx_add_sti_to_social_posts.rb
class AddStiToSocialPosts < ActiveRecord::Migration[7.0]
  def change
    # typeカラムを追加。既存のデータは全て通常の 'SocialPost' として扱うよう初期値を設定します
    add_column :social_posts, :type, :string, default: 'SocialPost', null: false

    # source_post_idを追加。参照先が自分自身(social_posts)であることを指定します
    add_reference :social_posts, :source_post, foreign_key: { to_table: :social_posts }, null: true

    # 検索パフォーマンス向上のためのインデックス
    add_index :social_posts, :type
  end
end
