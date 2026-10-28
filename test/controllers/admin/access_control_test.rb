require "test_helper"

module Admin
  class AccessControlTest < ActionDispatch::IntegrationTest
    def admin_paths
      [ admin_root_path, admin_categories_path, admin_courses_path, admin_lessons_path, admin_users_path, admin_reviews_path ]
    end

    test "sin iniciar sesión todas las secciones redirigen al login" do
      admin_paths.each do |path|
        get path
        assert_redirected_to login_path
      end
    end

    test "un admin con sesión iniciada accede a todas las secciones" do
      sign_in_as_admin

      admin_paths.each do |path|
        get path
        assert_response :success
      end
    end

    test "el menú muestra todas las secciones y el nombre del admin" do
      admin = sign_in_as_admin

      get admin_root_path
      assert_select "nav a", text: "Categorías"
      assert_select "nav a", text: "Cursos"
      assert_select "nav a", text: "Lecciones"
      assert_select "nav a", text: "Usuarios"
      assert_select "nav a", text: "Reseñas"
      assert_select ".user-box span", text: admin.name
    end
  end
end
