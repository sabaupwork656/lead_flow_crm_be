class User < ApplicationRecord
  belongs_to :workspace
  has_many :assigned_leads, class_name: "Lead", foreign_key: :assigned_to_id, dependent: :nullify
  has_many :notes, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  has_secure_password

  ROLES = %w[owner manager staff].freeze

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  before_validation :normalize_email

  def owner?
    role == "owner"
  end

  def manager?
    role == "manager"
  end

  def staff?
    role == "staff"
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
