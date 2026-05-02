class Lead < ApplicationRecord
  belongs_to :workspace
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :notes, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  STATUSES = ["New", "Contacted", "Qualified", "Proposal Sent", "Won", "Lost"].freeze
  PRIORITIES = %w[Low Medium High].freeze

  validates :name, presence: true
  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }
end
