ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Métodos para crear datos de prueba sin depender de fixtures
module TestFactory
  def create_user(role: "alumno", password: "123456", **attrs)
    User.create!({
      name: "#{role.capitalize} #{SecureRandom.hex(3)}",
      email: "#{role}_#{SecureRandom.hex(4)}@test.com",
      password: password,
      role: role
    }.merge(attrs))
  end

  def create_category(**attrs)
    Category.create!({ name: "Categoría #{SecureRandom.hex(3)}", description: "Descripción" }.merge(attrs))
  end

  def create_course(category: nil, professor: nil, **attrs)
    Course.create!({
      title: "Curso #{SecureRandom.hex(3)}",
      description: "Descripción del curso",
      price: 100,
      category: category || create_category,
      user: professor || create_user(role: "profesor")
    }.merge(attrs))
  end

  def create_lesson(course:, **attrs)
    Lesson.create!({ title: "Lección #{SecureRandom.hex(3)}", content: "Contenido", position: 1, course: course }.merge(attrs))
  end

  def create_enrollment(user:, course:, status: :activa)
    Enrollment.create!(user: user, course: course, status: status)
  end

  def create_review(user:, course:, **attrs)
    Review.create!({ rating: 5, comment: "Muy bueno", user: user, course: course }.merge(attrs))
  end
end

module ActiveSupport
  class TestCase
    include TestFactory
  end
end
