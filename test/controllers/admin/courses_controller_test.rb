require "test_helper"

module Admin
  class CoursesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as_admin
      @category = create_category
      @professor = create_user(role: "profesor")
    end

    def course_params(**overrides)
      { course: { title: "Rails desde cero", description: "Introducción", price: 1500, category_id: @category.id, user_id: @professor.id }.merge(overrides) }
    end

    test "index lista los cursos con su categoría y profesor" do
      create_course(title: "Rails avanzado", category: @category, professor: @professor)

      get admin_courses_path
      assert_response :success
      assert_select "td", text: "Rails avanzado"
      assert_select "td", text: @category.name
      assert_select "td", text: @professor.name
    end

    test "new ofrece solo a los profesores en el selector" do
      alumno = create_user(name: "Alumno Curioso")

      get new_admin_course_path
      assert_response :success
      assert_select "option", text: @professor.name
      assert_select "option", text: alumno.name, count: 0
    end

    test "create guarda un curso válido" do
      assert_difference "Course.count", 1 do
        post admin_courses_path, params: course_params
      end
      assert_redirected_to admin_courses_path
      assert_equal "Rails desde cero", Course.order(:id).last.title
    end

    test "create con precio negativo no guarda el curso" do
      assert_no_difference "Course.count" do
        post admin_courses_path, params: course_params(price: -5)
      end
      assert_response :unprocessable_entity
    end

    test "create permite subir una imagen de portada" do
      portada = Rack::Test::UploadedFile.new(StringIO.new("contenido"), "image/png", original_filename: "portada.png")

      post admin_courses_path, params: course_params(cover_image: portada)

      assert Course.order(:id).last.cover_image.attached?
    end

    test "update modifica el curso" do
      course = create_course(category: @category, professor: @professor)

      patch admin_course_path(course), params: { course: { title: "Título nuevo" } }
      assert_redirected_to admin_courses_path
      assert_equal "Título nuevo", course.reload.title
    end

    test "destroy elimina el curso" do
      course = create_course

      assert_difference "Course.count", -1 do
        delete admin_course_path(course)
      end
      assert_redirected_to admin_courses_path
    end
  end
end
