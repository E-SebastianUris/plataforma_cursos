require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user(role: "admin")
  end

  test "muestra el formulario de login" do
    get login_path
    assert_response :success
    assert_select "form"
  end

  test "loguea correctamente a un admin" do
    post login_path, params: { email: @admin.email, password: "123456" }
    assert_redirected_to admin_root_path
  end

  test "rechaza una contraseña incorrecta" do
    post login_path, params: { email: @admin.email, password: "mala" }
    assert_response :unprocessable_entity
  end

  test "rechaza un email inexistente" do
    post login_path, params: { email: "nadie@test.com", password: "123456" }
    assert_response :unprocessable_entity
  end

  test "no deja entrar al back office a un alumno" do
    alumno = create_user(role: "alumno")
    post login_path, params: { email: alumno.email, password: "123456" }
    assert_response :unprocessable_entity

    get admin_root_path
    assert_redirected_to login_path
  end

  test "cerrar sesión impide volver a entrar al back office" do
    sign_in_as_admin(@admin)
    delete logout_path
    assert_redirected_to login_path

    get admin_root_path
    assert_redirected_to login_path
  end
end
