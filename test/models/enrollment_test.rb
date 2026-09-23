require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Alumno", email: "alumno_test@test.com", password: "123456", role: "alumno")
    @prof = User.create!(name: "Prof", email: "prof_test2@test.com", password: "123456", role: "profesor")
    @category = Category.create!(name: "Categoria Test 2")
    @course = Course.create!(title: "Curso Test 2", description: "Desc", price: 100, category: @category, user: @prof)
  end

  test "no permite inscribirse dos veces al mismo curso" do
    Enrollment.create!(user: @user, course: @course, status: :pendiente)
    duplicate = Enrollment.new(user: @user, course: @course, status: :pendiente)
    assert_not duplicate.valid?
  end

  test "permite inscribirse a un curso distinto" do
    otro_curso = Course.create!(title: "Curso Test 3", description: "Desc", price: 50, category: @category, user: @prof)
    Enrollment.create!(user: @user, course: @course, status: :pendiente)
    enrollment2 = Enrollment.new(user: @user, course: otro_curso, status: :pendiente)
    assert enrollment2.valid?
  end
end
