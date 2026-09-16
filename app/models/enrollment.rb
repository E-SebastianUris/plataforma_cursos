class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum :status, { active: 0, completed: 1, cancelled: 2 }, default: :active
  validates :user_id, uniqueness: { scope: :course_id, message: "ya está inscripto en este curso" }
end