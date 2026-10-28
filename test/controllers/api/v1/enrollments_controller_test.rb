require "test_helper"

module Api
  module V1
    class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
      setup do
        ActionMailer::Base.deliveries.clear
        @alumno = create_user
        @course = create_course
      end

      test "index devuelve solo las inscripciones del usuario autenticado" do
        otro_alumno = create_user
        create_enrollment(user: @alumno, course: @course)
        create_enrollment(user: otro_alumno, course: create_course)

        get api_v1_orders_path, headers: auth_headers_for(@alumno)

        assert_response :success
        json = response.parsed_body
        assert_equal 1, json.size
        assert_equal @course.title, json.first["course"]["title"]
      end

      test "create inscribe al alumno con estado pendiente" do
        assert_difference "Enrollment.count", 1 do
          post api_v1_orders_path, params: { course_id: @course.id }, headers: auth_headers_for(@alumno), as: :json
        end

        assert_response :created
        enrollment = Enrollment.find_by(user: @alumno, course: @course)
        assert enrollment.pendiente?
        assert_equal @course.id, response.parsed_body["course_id"]
      end

      test "create envía el email de confirmación al alumno" do
        perform_enqueued_jobs do
          post api_v1_orders_path, params: { course_id: @course.id }, headers: auth_headers_for(@alumno), as: :json
        end

        assert_equal 1, ActionMailer::Base.deliveries.size
        email = ActionMailer::Base.deliveries.last
        assert_equal [ @alumno.email ], email.to
        assert_equal "Confirmación de inscripción a #{@course.title}", email.subject
      end

      test "create no permite inscribirse dos veces al mismo curso" do
        headers = auth_headers_for(@alumno)
        post api_v1_orders_path, params: { course_id: @course.id }, headers: headers, as: :json
        assert_response :created

        assert_no_difference "Enrollment.count" do
          post api_v1_orders_path, params: { course_id: @course.id }, headers: headers, as: :json
        end
        assert_response :unprocessable_entity
        assert_match(/ya está inscripto/, response.parsed_body["errors"].first)
      end

      test "create con un curso inexistente devuelve 404" do
        post api_v1_orders_path, params: { course_id: 0 }, headers: auth_headers_for(@alumno), as: :json

        assert_response :not_found
        assert_equal "Curso no encontrado", response.parsed_body["error"]
      end
    end
  end
end
