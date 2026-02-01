# app/models/note.rb
class Note < ApplicationRecord
  has_one :work, as: :actable, dependent: :destroy
  has_one :activity, through: :work

  # Googleドキュメント風のリッチテキストを扱う（画像添付も可能）
  has_rich_text :content
end
