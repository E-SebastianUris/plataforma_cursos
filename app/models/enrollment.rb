class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum :status, { pendiente: 0, activa: 1, completada: 2, cancelada: 3 }

  validates :user_id, uniqueness: { scope: :course_id, message: "ya está inscripto en este curso" }
end
