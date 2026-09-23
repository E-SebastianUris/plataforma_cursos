require "test_helper"

class CourseTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Prof", email: "prof_test@test.com", password: "123456", role: "profesor")
    @category = Category.create!(name: "Categoria Test")
  end

  test "es válido con datos correctos" do
    course = Course.new(title: "Curso Test", description: "Desc", price: 100, category: @category, user: @user)
    assert course.valid?
  end

  test "no es válido con precio negativo" do
    course = Course.new(title: "Curso Test", description: "Desc", price: -10, category: @category, user: @user)
    assert_not course.valid?
  end

  test "no es válido sin título" do
    course = Course.new(description: "Desc", price: 100, category: @category, user: @user)
    assert_not course.valid?
  end
end
