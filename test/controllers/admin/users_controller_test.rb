require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = sign_in_as_admin
    end

    def user_params(**overrides)
      { user: { name: "Profesor Nuevo", email: "nuevo@test.com", password: "123456", role: "profesor" }.merge(overrides) }
    end

    test "index lista los usuarios con su rol" do
      create_user(role: "profesor", name: "Profe Visible")

      get admin_users_path
      assert_response :success
      assert_select "td", text: "Profe Visible"
      assert_select "td", text: "Profesor"
    end

    test "create guarda un profesor nuevo" do
      assert_difference "User.count", 1 do
        post admin_users_path, params: user_params
      end
      assert_redirected_to admin_users_path
      assert User.find_by(email: "nuevo@test.com").profesor?
    end

    test "create rechaza un rol que no existe" do
      assert_no_difference "User.count" do
        post admin_users_path, params: user_params(role: "superusuario")
      end
      assert_response :unprocessable_entity
    end

    test "create rechaza un email repetido" do
      create_user(email: "nuevo@test.com")

      assert_no_difference "User.count" do
        post admin_users_path, params: user_params
      end
      assert_response :unprocessable_entity
    end

    test "update sin contraseña conserva la anterior" do
      user = create_user(password: "original1")

      patch admin_user_path(user), params: { user: { name: "Nombre nuevo", password: "", role: "alumno" } }
      assert_redirected_to admin_users_path
      assert_equal "Nombre nuevo", user.reload.name
      assert user.authenticate("original1")
    end

    test "update con contraseña la reemplaza" do
      user = create_user(password: "original1")

      patch admin_user_path(user), params: { user: { password: "nueva-clave", role: "alumno" } }
      assert user.reload.authenticate("nueva-clave")
      assert_not user.authenticate("original1")
    end

    test "update cambia el rol" do
      user = create_user(role: "alumno")

      patch admin_user_path(user), params: { user: { role: "profesor" } }
      assert user.reload.profesor?
    end

    test "destroy elimina a otro usuario" do
      user = create_user

      assert_difference "User.count", -1 do
        delete admin_user_path(user)
      end
      assert_redirected_to admin_users_path
    end

    test "destroy no permite que el admin elimine su propio usuario" do
      assert_no_difference "User.count" do
        delete admin_user_path(@admin)
      end
      assert_redirected_to admin_users_path

      follow_redirect!
      assert_select ".flash.alert", text: "No podés eliminar tu propio usuario"
    end
  end
end
