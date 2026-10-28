require "test_helper"

module Api
  module V1
    class AuthenticationTest < ActionDispatch::IntegrationTest
      test "los endpoints protegidos rechazan las peticiones sin token" do
        course = create_course

        get api_v1_profile_path
        assert_response :unauthorized

        get api_v1_orders_path
        assert_response :unauthorized

        post api_v1_orders_path, params: { course_id: course.id }, as: :json
        assert_response :unauthorized

        post api_v1_course_reviews_path(course), params: { rating: 5, comment: "Sin token" }, as: :json
        assert_response :unauthorized
        assert_equal "No autorizado", response.parsed_body["error"]
      end

      test "los endpoints públicos no piden token" do
        course = create_course

        get api_v1_courses_path
        assert_response :success

        get api_v1_course_path(course)
        assert_response :success

        get api_v1_course_reviews_path(course)
        assert_response :success
      end
    end
  end
end
