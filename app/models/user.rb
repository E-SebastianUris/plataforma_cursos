class User < ApplicationRecord
  has_secure_password

  enum :role, { student: 0, teacher: 1, admin: 2 }, default: :student

  has_many :courses, foreign_key: :user_id, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end