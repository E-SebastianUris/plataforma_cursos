require "test_helper"

module Api
  module V1
    class UsersControllerTest < ActionDispatch::IntegrationTest
      test "profile devuelve los datos del usuario autenticado" do
        alumno = create_user(name: "Ana Gomez")

        get api_v1_profile_path, headers: auth_headers_for(alumno)

        assert_response :success
        json = response.parsed_body
        assert_equal alumno.id, json["id"]
        assert_equal "Ana Gomez", json["name"]
        assert_equal alumno.email, json["email"]
        assert_equal "alumno", json["role"]
        assert_equal [ "email", "id", "name", "role" ], json.keys.sort
      end

      test "profile sin token devuelve 401" do
        get api_v1_profile_path

        assert_response :unauthorized
      end

      test "profile con un token inválido devuelve 401" do
        get api_v1_profile_path, headers: { "Authorization" => "Bearer token-falso" }

        assert_response :unauthorized
      end

      test "update actualiza nombre y email del usuario autenticado" do
        alumno = create_user(name: "Ana Gomez")

        put api_v1_profile_path, params: { name: "Ana Maria Gomez", email: "ana.nueva@test.com" },
                                 headers: auth_headers_for(alumno), as: :json

        assert_response :success
        json = response.parsed_body
        assert_equal "Ana Maria Gomez", json["name"]
        assert_equal "ana.nueva@test.com", json["email"]
        assert_equal "Ana Maria Gomez", alumno.reload.name
        assert_equal "ana.nueva@test.com", alumno.email
      end

      test "update con datos inválidos devuelve 422" do
        alumno = create_user(name: "Ana Gomez")

        put api_v1_profile_path, params: { name: "", email: "invalido" },
                                 headers: auth_headers_for(alumno), as: :json

        assert_response :unprocessable_entity
        assert response.parsed_body["errors"].is_a?(Array)
      end
    end
  end
end
