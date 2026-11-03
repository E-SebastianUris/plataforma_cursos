require "test_helper"

module Api
  module V1
    class CategoriesControllerTest < ActionDispatch::IntegrationTest
      test "index devuelve lista de categorias ordenada con id y name" do
        create_category(name: "Programacion")
        create_category(name: "Diseno")

        get api_v1_categories_path

        assert_response :success
        json = response.parsed_body
        assert json.size >= 2
        primer = json.first
        assert_equal [ "id", "name" ], primer.keys.sort
      end
    end
  end
end
