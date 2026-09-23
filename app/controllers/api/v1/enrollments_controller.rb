module Api
  module V1
    class EnrollmentsController < BaseController
      def index
        enrollments = current_user.enrollments.includes(:course)
        render json: enrollments.as_json(include: { course: { only: [ :id, :title, :price ] } })
      end

      def create
        course = Course.find(params[:course_id])
        enrollment = current_user.enrollments.new(course: course, status: :pendiente)
        if enrollment.save
          EnrollmentMailer.confirmation(enrollment).deliver_later
          render json: enrollment, status: :created
        else
          render json: { errors: enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Curso no encontrado" }, status: :not_found
      end
    end
  end
end
