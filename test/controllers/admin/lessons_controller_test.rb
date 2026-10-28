require "test_helper"

module Admin
  class LessonsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as_admin
      @course = create_course
    end

    def lesson_params(**overrides)
      { lesson: { title: "Instalación", content: "Cómo instalar Ruby", position: 1, course_id: @course.id }.merge(overrides) }
    end

    test "index lista las lecciones con su curso" do
      create_lesson(course: @course, title: "Primeros pasos")

      get admin_lessons_path
      assert_response :success
      assert_select "td", text: "Primeros pasos"
      assert_select "td", text: @course.title
    end

    test "create guarda una lección válida" do
      assert_difference "Lesson.count", 1 do
        post admin_lessons_path, params: lesson_params
      end
      assert_redirected_to admin_lessons_path
    end

    test "create sin título no guarda la lección" do
      assert_no_difference "Lesson.count" do
        post admin_lessons_path, params: lesson_params(title: "")
      end
      assert_response :unprocessable_entity
    end

    test "update modifica la lección" do
      lesson = create_lesson(course: @course)

      patch admin_lesson_path(lesson), params: { lesson: { title: "Título corregido" } }
      assert_redirected_to admin_lessons_path
      assert_equal "Título corregido", lesson.reload.title
    end

    test "destroy elimina la lección" do
      lesson = create_lesson(course: @course)

      assert_difference "Lesson.count", -1 do
        delete admin_lesson_path(lesson)
      end
      assert_redirected_to admin_lessons_path
    end
  end
end
