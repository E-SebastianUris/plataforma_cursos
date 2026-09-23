module Api
  module V1
    class CoursesController < ActionController::API
      def index
        courses = Course.includes(:category, :user)
        render json: courses.as_json(include: { category: { only: [ :id, :name ] }, user: { only: [ :id, :name ] } })
      end

      def show
        course = Course.includes(:lessons, :category, :user).find(params[:id])
        render json: course.as_json(include: [ :lessons, :category, :user ])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Curso no encontrado" }, status: :not_found
      end
    end
  end
end
