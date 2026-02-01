# app/models/work.rb
class Work < ApplicationRecord
  # Note, Table, Book などがここに紐付く
  belongs_to :actable, polymorphic: true, dependent: :destroy

  # Activity 側からの入り口
  has_one :activity, as: :actable, dependent: :destroy
  accepts_nested_attributes_for :activity
end
