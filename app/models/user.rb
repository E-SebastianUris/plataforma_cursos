class User < ApplicationRecord
  has_secure_password

  enum :role, { alumno: 0, profesor: 1, admin: 2 }

  has_many :courses, foreign_key: :user_id, dependent: :destroy  # cursos que dicta (si es profesor)
  has_many :enrollments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
