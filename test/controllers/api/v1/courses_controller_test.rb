require "test_helper"

module Api
  module V1
    class CoursesControllerTest < ActionDispatch::IntegrationTest
      test "index lista los cursos con su categoría y profesor sin pedir token" do
        course = create_course(title: "Rails desde cero", price: 1500.5)

        get api_v1_courses_path

        assert_response :success
        curso = response.parsed_body.find { |c| c["id"] == course.id }
        assert_equal "Rails desde cero", curso["title"]
        assert_equal course.category.name, curso["category"]["name"]
        assert_equal course.user.name, curso["user"]["name"]
        assert_equal 1500.5, curso["price"]
        assert_nil curso["cover_image_url"]
      end

      test "index incluye la url de la portada cuando tiene imagen adjunta" do
        course = create_course
        course.cover_image.attach(
          io: StringIO.new("<svg></svg>"),
          filename: "test.svg",
          content_type: "image/svg+xml"
        )

        get api_v1_courses_path

        curso = response.parsed_body.find { |c| c["id"] == course.id }
        assert_match %r{/rails/active_storage/blobs/}, curso["cover_image_url"]
      end

      test "index filtra por categoría" do
        cat1 = create_category(name: "Cat Uno")
        cat2 = create_category(name: "Cat Dos")
        c1 = create_course(category: cat1, title: "Curso de Cat Uno")
        c2 = create_course(category: cat2, title: "Curso de Cat Dos")

        get api_v1_courses_path, params: { category_id: cat1.id }

        assert_response :success
        ids = response.parsed_body.map { |c| c["id"] }
        assert_includes ids, c1.id
        assert_not_includes ids, c2.id
      end

      test "index busca por texto en título o descripción" do
        c1 = create_course(title: "React Avanzado", description: "Hooks y arquitectura")
        c2 = create_course(title: "Ruby on Rails", description: "Desarrollo backend")

        get api_v1_courses_path, params: { search: "React" }

        assert_response :success
        ids = response.parsed_body.map { |c| c["id"] }
        assert_includes ids, c1.id
        assert_not_includes ids, c2.id
      end

      test "index solo expone el id y el nombre del profesor" do
        course = create_course

        get api_v1_courses_path

        curso = response.parsed_body.find { |c| c["id"] == course.id }
        assert_equal [ "id", "name" ], curso["user"].keys.sort
      end

      test "show devuelve el curso con sus lecciones sin contenido para usuario no inscripto" do
        course = create_course
        create_lesson(course: course, title: "Introducción", content: "Contenido secreto", position: 1)

        get api_v1_course_path(course)

        assert_response :success
        json = response.parsed_body
        assert_equal course.title, json["title"]
        assert_equal 1, json["lessons"].size
        assert_nil json["lessons"].first["content"]
      end

      test "show devuelve el contenido de lecciones para alumno inscripto activo" do
        alumno = create_user
        course = create_course
        create_enrollment(user: alumno, course: course, status: :activa)
        create_lesson(course: course, title: "Introducción", content: "Contenido accesible", position: 1)

        get api_v1_course_path(course), headers: auth_headers_for(alumno)

        assert_response :success
        json = response.parsed_body
        assert_equal "Contenido accesible", json["lessons"].first["content"]
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
