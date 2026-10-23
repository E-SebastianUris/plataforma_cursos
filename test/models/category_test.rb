require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "es válida con nombre" do
    assert Category.new(name: "Programación").valid?
  end

  test "no es válida sin nombre" do
    category = Category.new(description: "Sin nombre")
    assert_not category.valid?
    assert_includes category.errors.attribute_names, :name
  end

  test "no es válida con un nombre repetido" do
    create_category(name: "Diseño")
    category = Category.new(name: "Diseño")
    assert_not category.valid?
    assert_includes category.errors.attribute_names, :name
  end

  test "al eliminarla se eliminan sus cursos" do
    category = create_category
    create_course(category: category)

    assert_difference "Course.count", -1 do
      category.destroy
    end
  end
end
