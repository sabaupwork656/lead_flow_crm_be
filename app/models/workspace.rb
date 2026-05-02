class Workspace < ApplicationRecord
  PLANS = ["Starter", "Growth", "Agency"].freeze

  has_many :users, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  validates :name, presence: true
  validates :plan, inclusion: { in: PLANS }
end
