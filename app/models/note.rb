class Note < ApplicationRecord
  belongs_to :lead
  belongs_to :user

  validates :body, presence: true
end
