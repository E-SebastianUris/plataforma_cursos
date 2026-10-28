require "test_helper"

module Api
  module V1
    class CoursesControllerTest < ActionDispatch::IntegrationTest
      test "index lista los cursos con su categoría y profesor sin pedir token" do
        course = create_course(title: "Rails desde cero")

        get api_v1_courses_path

        assert_response :success
        curso = response.parsed_body.find { |c| c["id"] == course.id }
        assert_equal "Rails desde cero", curso["title"]
        assert_equal course.category.name, curso["category"]["name"]
        assert_equal course.user.name, curso["user"]["name"]
      end

      test "index solo expone el id y el nombre del profesor" do
        course = create_course

        get api_v1_courses_path

        curso = response.parsed_body.find { |c| c["id"] == course.id }
        assert_equal [ "id", "name" ], curso["user"].keys.sort
      end

      test "show devuelve el curso con sus lecciones" do
        course = create_course
        create_lesson(course: course, title: "Introducción", position: 1)
        create_lesson(course: course, title: "Instalación", position: 2)

        get api_v1_course_path(course)

        assert_response :success
        json = response.parsed_body
        assert_equal course.title, json["title"]
        assert_equal 2, json["lessons"].size
      end

      test "show no expone la contraseña ni el token del profesor" do
        profesor = create_user(role: "profesor", auth_token: "token-secreto")
        course = create_course(professor: profesor)

        get api_v1_course_path(course)

        assert_equal [ "id", "name" ], response.parsed_body["user"].keys.sort
        assert_not_includes response.body, "token-secreto"
        assert_not_includes response.body, "password_digest"
      end

      test "show con un curso inexistente devuelve 404" do
        get api_v1_course_path(0)

        assert_response :not_found
        assert_equal "Curso no encontrado", response.parsed_body["error"]
      end
    end
  end
end
