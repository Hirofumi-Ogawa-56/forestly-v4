class CreateSocialPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :social_posts do |t|
      t.text :content
      t.datetime :edited_at

      t.timestamps
    end
  end
end
