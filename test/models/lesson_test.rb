require "test_helper"

class LessonTest < ActiveSupport::TestCase
  setup do
    @course = create_course
  end

  def build_lesson(**attrs)
    Lesson.new({ title: "Introducción", content: "Contenido", position: 1, course: @course }.merge(attrs))
  end

  test "es válida con datos correctos" do
    assert build_lesson.valid?
  end

  test "no es válida sin título" do
    lesson = build_lesson(title: nil)
    assert_not lesson.valid?
    assert_includes lesson.errors.attribute_names, :title
  end

  test "no es válida sin contenido" do
    lesson = build_lesson(content: nil)
    assert_not lesson.valid?
    assert_includes lesson.errors.attribute_names, :content
  end

  test "no es válida sin posición" do
    lesson = build_lesson(position: nil)
    assert_not lesson.valid?
    assert_includes lesson.errors.attribute_names, :position
  end

  test "no es válida sin curso" do
    lesson = build_lesson(course: nil)
    assert_not lesson.valid?
    assert_includes lesson.errors.attribute_names, :course
  end
end