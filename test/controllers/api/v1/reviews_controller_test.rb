require "test_helper"

module Api
  module V1
    class ReviewsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @alumno = create_user
        @course = create_course
      end

      def post_review(user, course: @course, **params)
        post api_v1_course_reviews_path(course), params: params, headers: auth_headers_for(user), as: :json
      end

      # --- index (público) ---

      test "index devuelve el promedio, la cantidad y las reseñas del curso" do
        create_review(user: create_user, course: @course, rating: 5, comment: "Excelente")
        create_review(user: create_user, course: @course, rating: 4, comment: "Muy bueno")
        create_review(user: create_user, course: @course, rating: 3, comment: "Bien")

        get api_v1_course_reviews_path(@course)

        assert_response :success
        json = response.parsed_body
        assert_equal 4.0, json["average_rating"]
        assert_equal 3, json["reviews_count"]
        assert_equal 3, json["reviews"].size
      end

      test "index muestra el autor de cada reseña solo con id y nombre" do
        create_review(user: @alumno, course: @course)

        get api_v1_course_reviews_path(@course)

        review = response.parsed_body["reviews"].first
        assert_equal [ "comment", "created_at", "id", "rating", "user" ], review.keys.sort
        assert_equal [ "id", "name" ], review["user"].keys.sort
      end

      test "index de un curso sin reseñas devuelve promedio nulo" do
        get api_v1_course_reviews_path(@course)

        json = response.parsed_body
        assert_nil json["average_rating"]
        assert_equal 0, json["reviews_count"]
        assert_empty json["reviews"]
      end

      test "index no mezcla las reseñas de otros cursos" do
        create_review(user: @alumno, course: @course)
        create_review(user: @alumno, course: create_course)

        get api_v1_course_reviews_path(@course)

        assert_equal 1, response.parsed_body["reviews_count"]
      end

      test "index con un curso inexistente devuelve 404" do
        get api_v1_course_reviews_path(0)

        assert_response :not_found
      end

      # --- create (requiere token e inscripción) ---

      test "create permite reseñar a un alumno inscripto" do
        create_enrollment(user: @alumno, course: @course, status: :pendiente)

        assert_difference "Review.count", 1 do
          post_review(@alumno, rating: 5, comment: "Excelente")
        end

        assert_response :created
        json = response.parsed_body
        assert_equal 5, json["rating"]
        assert_equal "Excelente", json["comment"]
        assert_equal [ "comment", "created_at", "id", "rating" ], json.keys.sort
      end

      test "create rechaza a un alumno que no está inscripto" do
        assert_no_difference "Review.count" do
          post_review(@alumno, rating: 5, comment: "Sin estar inscripto")
        end

        assert_response :forbidden
      end

      test "create rechaza a un alumno con la inscripción cancelada" do
        create_enrollment(user: @alumno, course: @course, status: :cancelada)

        assert_no_difference "Review.count" do
          post_review(@alumno, rating: 5, comment: "Me di de baja")
        end

        assert_response :forbidden
      end

      test "create acepta inscripciones pendientes, activas y completadas" do
        %i[pendiente activa completada].each do |status|
          alumno = create_user
          create_enrollment(user: alumno, course: @course, status: status)

          post_review(alumno, rating: 4, comment: "Reseña con inscripción #{status}")

          assert_response :created
        end
      end

      test "create no permite reseñar dos veces el mismo curso" do
        create_enrollment(user: @alumno, course: @course)
        create_review(user: @alumno, course: @course)

        assert_no_difference "Review.count" do
          post_review(@alumno, rating: 3, comment: "Otra vez")
        end

        assert_response :unprocessable_entity
        assert_match(/ya dejó una reseña/, response.parsed_body["errors"].first)
      end

      test "create rechaza puntajes fuera del rango de 1 a 5" do
        create_enrollment(user: @alumno, course: @course)

        [ 0, 9 ].each do |rating|
          post_review(@alumno, rating: rating, comment: "Puntaje #{rating}")
          assert_response :unprocessable_entity
        end

        assert_equal 0, Review.count
      end

      test "create rechaza una reseña sin comentario" do
        create_enrollment(user: @alumno, course: @course)

        assert_no_difference "Review.count" do
          post_review(@alumno, rating: 5)
        end

        assert_response :unprocessable_entity
      end

      test "create con un curso inexistente devuelve 404" do
        post_review(@alumno, course: 0, rating: 5, comment: "No existe")

        assert_response :not_found
      end

      test "create ignora un user_id enviado y usa al usuario autenticado" do
        otro_alumno = create_user
        create_enrollment(user: @alumno, course: @course)

        post_review(@alumno, rating: 5, comment: "Mi reseña", user_id: otro_alumno.id)

        assert_response :created
        assert_equal @alumno, Review.order(:id).last.user
      end
    end
  end
end
