class TaskAssignee < ApplicationRecord
  belongs_to :task
  belongs_to :profile
end
