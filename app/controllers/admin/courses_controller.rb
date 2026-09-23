module Admin
  class CoursesController < BaseController
    before_action :set_course, only: %i[show edit update destroy]

    def index
      @courses = Course.includes(:category, :user).all
    end

    def show
    end

    def new
      @course = Course.new
    end

    def create
      @course = Course.new(course_params)
      if @course.save
        redirect_to admin_courses_path, notice: "Curso creado"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @course.update(course_params)
        redirect_to admin_courses_path, notice: "Curso actualizado"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course.destroy
      redirect_to admin_courses_path, notice: "Curso eliminado"
    end

    private

    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(:title, :description, :price, :category_id, :user_id, :cover_image)
    end
  end
end
