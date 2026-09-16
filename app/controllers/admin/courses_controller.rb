class Admin::CoursesController < ApplicationController
  before_action :set_admin_course, only: %i[ show edit update destroy ]

  # GET /admin/courses
  def index
    @admin_courses = Course.all
  end

  # GET /admin/courses/1
  def show
  end

  # GET /admin/courses/new
  def new
    @admin_course = Course.new
  end

  # GET /admin/courses/1/edit
  def edit
  end

  # POST /admin/courses
  def create
    @admin_course = Course.new(admin_course_params)

    respond_to do |format|
      if @admin_course.save
        format.html { redirect_to admin_course_path(@admin_course), notice: "Curso creado exitosamente." }
        format.json { render :show, status: :created, location: @admin_course }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @admin_course.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /admin/courses/1
  def update
    respond_to do |format|
      if @admin_course.update(admin_course_params)
        format.html { redirect_to admin_course_path(@admin_course), notice: "Curso actualizado exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @admin_course }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @admin_course.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /admin/courses/1
  def destroy
    @admin_course.destroy!

    respond_to do |format|
      format.html { redirect_to admin_courses_path, notice: "Curso eliminado exitosamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_admin_course
    @admin_course = Course.find(params[:id])
  end

  def admin_course_params
    params.require(:course).permit(:title, :description, :price, :category_id, :user_id)
  end
end