module Api
  module V1
    class CoursesController < ActionController::API
      def index
        courses = Course.includes(:category, :user).all
        courses = courses.where(category_id: params[:category_id]) if params[:category_id].present?
        if params[:search].present?
          term = "%#{params[:search]}%"
          courses = courses.where("title LIKE ? OR description LIKE ?", term, term)
        end
        render json: courses.map { |c| serialize_course(c) }
      end

      def show
        course = Course.includes(:lessons, :category, :user).find(params[:id])
        enrolled = active_enrollment?(course)
        lessons = course.lessons.map { |l| lesson_json(l, enrolled) }
        render json: serialize_course(course).merge(lessons: lessons)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Curso no encontrado" }, status: :not_found
      end

      private

      def serialize_course(course)
        course.as_json(
          only: [ :id, :title, :description, :price ],
          include: {
            category: { only: [ :id, :name ] },
            user: { only: [ :id, :name ] }
          }
        ).merge(
          "price" => course.price.to_f,
          "cover_image_url" => cover_url(course)
        )
      end

      def lesson_json(lesson, enrolled)
        json = lesson.as_json(only: [ :id, :title, :position ])
        json["content"] = enrolled ? lesson.content : nil
        json
      end

      def cover_url(course)
        return nil unless course.cover_image.attached?

        "#{request.protocol}#{request.host_with_port}#{Rails.application.routes.url_helpers.rails_blob_path(course.cover_image, only_path: true)}"
      rescue StandardError
        nil
      end

      def active_enrollment?(course)
        header = request.headers["Authorization"]
        token = header&.split(" ")&.last
        return false unless token

        user = User.find_by(auth_token: token)
        return false unless user

        user.enrollments.exists?(course: course, status: :activa)
      end
    end
  end
end
