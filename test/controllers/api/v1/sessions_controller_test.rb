require "test_helper"

module Api
  module V1
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @alumno = create_user(name: "Juan Perez", password: "secreta1")
      end

      test "login válido devuelve el token y los datos del usuario" do
        post api_v1_login_path, params: { email: @alumno.email, password: "secreta1" }, as: :json

        assert_response :success
        json = response.parsed_body
        assert json["token"].present?
        assert_equal @alumno.reload.auth_token, json["token"]
        assert_equal "alumno", json["user"]["role"]
        assert_equal [ "id", "name", "role" ], json["user"].keys.sort
      end

      test "login con contraseña incorrecta devuelve 401" do
        post api_v1_login_path, params: { email: @alumno.email, password: "mala" }, as: :json

        assert_response :unauthorized
        assert_equal "Credenciales inválidas", response.parsed_body["error"]
      end

      test "login con un email inexistente devuelve 401" do
        post api_v1_login_path, params: { email: "nadie@test.com", password: "secreta1" }, as: :json

        assert_response :unauthorized
      end

      test "cada login genera un token nuevo" do
        post api_v1_login_path, params: { email: @alumno.email, password: "secreta1" }, as: :json
        primero = response.parsed_body["token"]

        post api_v1_login_path, params: { email: @alumno.email, password: "secreta1" }, as: :json
        segundo = response.parsed_body["token"]

        assert_not_equal primero, segundo
      end
    end
  end
end
