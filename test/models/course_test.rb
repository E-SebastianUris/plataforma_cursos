require "test_helper"

class CourseTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @professor = create_user(role: "profesor")
    @category = create_category
  end

  def build_course(**attrs)
    Course.new({ title: "Curso Test", description: "Descripción", price: 100, category: @category, user: @professor }.merge(attrs))
  end

  test "es válido con datos correctos" do
    assert build_course.valid?
  end

  test "no es válido sin título" do
    course = build_course(title: nil)
    assert_not course.valid?
    assert_includes course.errors.attribute_names, :title
  end

  test "no es válido sin descripción" do
    course = build_course(description: nil)
    assert_not course.valid?
    assert_includes course.errors.attribute_names, :description
  end

  test "no es válido sin precio" do
    course = build_course(price: nil)
    assert_not course.valid?
    assert_includes course.errors.attribute_names, :price
  end

  test "no es válido con precio negativo" do
    course = build_course(price: -10)
    assert_not course.valid?
    assert_includes course.errors.attribute_names, :price
  end

  test "permite un curso gratuito con precio cero" do
    assert build_course(price: 0).valid?
  end

  test "no es válido sin categoría" do
    course = build_course(category: nil)
    assert_not course.valid?
    assert_includes course.errors.attribute_names, :category
  end

  test "no es válido sin profesor" do
    course = build_course(user: nil)
    assert_not course.valid?
    assert_includes course.errors.attribute_names, :user
  end

  test "al eliminarlo se eliminan sus lecciones, inscripciones y reseñas" do
    course = create_course
    alumno = create_user
    create_lesson(course: course)
    create_enrollment(user: alumno, course: course)
    create_review(user: alumno, course: course)

    assert_difference [ "Lesson.count", "Enrollment.count", "Review.count" ], -1 do
      course.destroy
    end
  end

  test "students devuelve los alumnos inscriptos" do
    course = create_course
    alumno = create_user
    create_enrollment(user: alumno, course: course)

    assert_includes course.students, alumno
  end

  test "permite adjuntar una imagen de portada" do
    course = create_course
    course.cover_image.attach(io: StringIO.new("contenido"), filename: "portada.png", content_type: "image/png")

    assert course.cover_image.attached?
  end
end
