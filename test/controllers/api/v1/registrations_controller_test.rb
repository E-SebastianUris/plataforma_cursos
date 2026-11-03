require "test_helper"

module Api
  module V1
    class RegistrationsControllerTest < ActionDispatch::IntegrationTest
      test "registro exitoso crea usuario alumno y devuelve token" do
        assert_difference "User.count", 1 do
          post api_v1_register_path, params: {
            name: "Nuevo Alumno",
            email: "nuevo_alumno@test.com",
            password: "password123",
            password_confirmation: "password123"
          }, as: :json
        end

        assert_response :created
        json = response.parsed_body
        assert json["token"].present?
        assert_equal "Nuevo Alumno", json["user"]["name"]
        assert_equal "alumno", json["user"]["role"]

        user = User.find_by(email: "nuevo_alumno@test.com")
        assert user.alumno?
        assert_equal user.auth_token, json["token"]
      end

      test "registro ignora intento de asignarse rol admin o profesor" do
        post api_v1_register_path, params: {
          name: "Hacker",
          email: "hacker@test.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        }, as: :json

        assert_response :created
        user = User.find_by(email: "hacker@test.com")
        assert user.alumno?
        assert_equal "alumno", response.parsed_body["user"]["role"]
      end

      test "registro con datos invalidos devuelve 422 y lista de errores" do
        assert_no_difference "User.count" do
          post api_v1_register_path, params: {
            name: "",
            email: "email-invalido",
            password: "123",
            password_confirmation: "456"
          }, as: :json
        end

        assert_response :unprocessable_entity
        assert response.parsed_body["errors"].is_a?(Array)
        assert response.parsed_body["errors"].any?
      end

      test "registro con email duplicado devuelve 422" do
        create_user(email: "duplicado@test.com")

        post api_v1_register_path, params: {
          name: "Otro",
          email: "duplicado@test.com",
          password: "password123",
          password_confirmation: "password123"
        }, as: :json

        assert_response :unprocessable_entity
      end
    end
  end
end
