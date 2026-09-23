require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin Test", email: "admin_test@test.com", password: "123456", role: "admin")
  end

  test "muestra el formulario de login" do
    get login_path
    assert_response :success
  end

  test "loguea correctamente a un admin" do
    post login_path, params: { email: @admin.email, password: "123456" }
    assert_redirected_to admin_root_path
  end

  test "rechaza credenciales incorrectas" do
    post login_path, params: { email: @admin.email, password: "mala" }
    assert_response :unprocessable_entity
  end
end
