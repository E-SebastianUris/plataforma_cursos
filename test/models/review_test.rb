require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @alumno = create_user
    @course = create_course
  end

  def build_review(**attrs)
    Review.new({ rating: 5, comment: "Muy bueno", user: @alumno, course: @course }.merge(attrs))
  end

  test "es válida con datos correctos" do
    assert build_review.valid?
  end

  test "no es válida sin puntaje" do
    review = build_review(rating: nil)
    assert_not review.valid?
    assert_includes review.errors.attribute_names, :rating
  end

  test "no acepta puntajes fuera del rango de 1 a 5" do
    [ 0, 6 ].each do |rating|
      assert_not build_review(rating: rating).valid?, "no debería aceptar el puntaje #{rating}"
    end
  end

  test "acepta los puntajes límite 1 y 5" do
    [ 1, 5 ].each do |rating|
      assert build_review(rating: rating).valid?, "debería aceptar el puntaje #{rating}"
    end
  end

  test "no es válida sin comentario" do
    review = build_review(comment: nil)
    assert_not review.valid?
    assert_includes review.errors.attribute_names, :comment
  end

  test "un alumno no puede reseñar dos veces el mismo curso" do
    create_review(user: @alumno, course: @course)
    duplicate = build_review(rating: 3, comment: "Otra vez")

    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :user_id
  end

  test "dos alumnos pueden reseñar el mismo curso" do
    create_review(user: @alumno, course: @course)

    assert build_review(user: create_user).valid?
  end

  test "un alumno puede reseñar cursos distintos" do
    create_review(user: @alumno, course: @course)

    assert build_review(course: create_course).valid?
  end
end