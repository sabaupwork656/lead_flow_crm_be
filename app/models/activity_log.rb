class ActivityLog < ApplicationRecord
  belongs_to :workspace
  belongs_to :lead, optional: true
  belongs_to :user

  validates :action, presence: true
end
