require "test_helper"

module Admin
  class CategoriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as_admin
    end

    test "index lista las categorías" do
      create_category(name: "Backend")

      get admin_categories_path
      assert_response :success
      assert_select "td", text: "Backend"
    end

    test "new muestra el formulario" do
      get new_admin_category_path
      assert_response :success
      assert_select "form"
    end

    test "create guarda una categoría válida y muestra el aviso" do
      assert_difference "Category.count", 1 do
        post admin_categories_path, params: { category: { name: "Diseño", description: "Cursos de diseño" } }
      end
      assert_redirected_to admin_categories_path

      follow_redirect!
      assert_select ".flash.notice", text: "Categoría creada"
    end

    test "create sin nombre no guarda la categoría" do
      assert_no_difference "Category.count" do
        post admin_categories_path, params: { category: { name: "" } }
      end
      assert_response :unprocessable_entity
    end

    test "edit muestra el formulario con los datos actuales" do
      category = create_category(name: "Redes")

      get edit_admin_category_path(category)
      assert_response :success
      assert_select "input[value=?]", "Redes"
    end

    test "update modifica la categoría" do
      category = create_category(name: "Redes")

      patch admin_category_path(category), params: { category: { name: "Redes y comunicaciones" } }
      assert_redirected_to admin_categories_path
      assert_equal "Redes y comunicaciones", category.reload.name
    end

    test "update con un nombre vacío no modifica la categoría" do
      category = create_category(name: "Redes")

      patch admin_category_path(category), params: { category: { name: "" } }
      assert_response :unprocessable_entity
      assert_equal "Redes", category.reload.name
    end

    test "destroy elimina la categoría" do
      category = create_category

      assert_difference "Category.count", -1 do
        delete admin_category_path(category)
      end
      assert_redirected_to admin_categories_path
    end
  end
end
