# app/models/task.rb
class Task < ApplicationRecord
  has_one :activity, as: :actable, dependent: :destroy
  accepts_nested_attributes_for :activity

  # 担当者（複数）の紐付け
  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees, source: :profile

  # エラー回避のため命名をDBカラムに合わせて統一
  enum :task_status, { todo: 0, in_progress: 1, done: 2, backlog: 3 }
end
