# app/models/like.rb
class Like < ApplicationRecord
  has_one :activity, as: :actable, dependent: :destroy
end
