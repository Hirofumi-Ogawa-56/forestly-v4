# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :profiles, dependent: :destroy
  # User作成時にProfileも一緒に作れるようにする設定
  accepts_nested_attributes_for :profiles
end
