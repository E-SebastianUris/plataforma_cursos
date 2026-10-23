require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  setup do
    @alumno = create_user
    @course = create_course
  end

  test "es válida con alumno, curso y estado" do
    assert Enrollment.new(user: @alumno, course: @course, status: :pendiente).valid?
  end

  test "no es válida sin alumno" do
    enrollment = Enrollment.new(course: @course, status: :pendiente)
    assert_not enrollment.valid?
    assert_includes enrollment.errors.attribute_names, :user
  end

  test "no es válida sin curso" do
    enrollment = Enrollment.new(user: @alumno, status: :pendiente)
    assert_not enrollment.valid?
    assert_includes enrollment.errors.attribute_names, :course
  end

  test "no permite inscribirse dos veces al mismo curso" do
    create_enrollment(user: @alumno, course: @course)
    duplicate = Enrollment.new(user: @alumno, course: @course, status: :pendiente)

    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :user_id
  end

  test "permite inscribirse a un curso distinto" do
    create_enrollment(user: @alumno, course: @course)
    otro_curso = create_course

    assert Enrollment.new(user: @alumno, course: otro_curso, status: :pendiente).valid?
  end

  test "permite que dos alumnos se inscriban al mismo curso" do
    create_enrollment(user: @alumno, course: @course)
    otro_alumno = create_user

    assert Enrollment.new(user: otro_alumno, course: @course, status: :pendiente).valid?
  end

  test "los estados disponibles son pendiente, activa, completada y cancelada" do
    assert_equal %w[pendiente activa completada cancelada], Enrollment.statuses.keys
  end

  test "cambia de estado con los métodos del enum" do
    enrollment = create_enrollment(user: @alumno, course: @course, status: :pendiente)
    enrollment.activa!

    assert enrollment.activa?
  end
end
