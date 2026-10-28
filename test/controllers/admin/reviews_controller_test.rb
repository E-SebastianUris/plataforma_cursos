require "test_helper"

module Admin
  class ReviewsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as_admin
      @alumno = create_user(name: "Alumno Reseñador")
      @course = create_course(title: "Curso reseñado")
      @review = create_review(user: @alumno, course: @course, rating: 4, comment: "Buen contenido")
    end

    test "index lista las reseñas con curso, alumno y comentario" do
      get admin_reviews_path
      assert_response :success
      assert_select "td", text: "Curso reseñado"
      assert_select "td", text: "Alumno Reseñador"
      assert_select "td", text: "Buen contenido"
    end

    test "index muestra el puntaje con estrellas" do
      get admin_reviews_path
      assert_select "td", text: "★★★★☆"
    end

    test "destroy elimina la reseña como moderación" do
      assert_difference "Review.count", -1 do
        delete admin_review_path(@review)
      end
      assert_redirected_to admin_reviews_path

      follow_redirect!
      assert_select ".flash.notice", text: "Reseña eliminada"
    end
  end
end
