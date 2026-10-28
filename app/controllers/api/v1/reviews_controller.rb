module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_user!, only: :index
      before_action :set_course

      def index
        reviews = @course.reviews.includes(:user).order(created_at: :desc)
        render json: {
          average_rating: @course.reviews.average(:rating)&.to_f&.round(1),
          reviews_count: @course.reviews.count,
          reviews: reviews.as_json(only: [ :id, :rating, :comment, :created_at ], include: { user: { only: [ :id, :name ] } })
        }
      end

      def create
        unless enrolled?
          return render json: { error: "Tenés que estar inscripto en el curso para reseñarlo" }, status: :forbidden
        end

        review = @course.reviews.new(review_params.merge(user: current_user))
        if review.save
          render json: review.as_json(only: [ :id, :rating, :comment, :created_at ]), status: :created
        else
          render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_course
        @course = Course.find(params[:course_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Curso no encontrado" }, status: :not_found
      end

      def enrolled?
        current_user.enrollments.where(course: @course).where.not(status: :cancelada).exists?
      end

      def review_params
        params.slice(:rating, :comment).permit(:rating, :comment)
      end
    end
  end
end
