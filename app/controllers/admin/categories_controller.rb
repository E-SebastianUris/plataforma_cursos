class Admin::CategoriesController < ApplicationController
  before_action :set_admin_category, only: %i[ show edit update destroy ]

  # GET /admin/categories
  def index
    @admin_categories = Category.all
  end

  # GET /admin/categories/1
  def show
  end

  # GET /admin/categories/new
  def new
    @admin_category = Category.new
  end

  # GET /admin/categories/1/edit
  def edit
  end

  # POST /admin/categories
  def create
    @admin_category = Category.new(admin_category_params)

    respond_to do |format|
      if @admin_category.save
        format.html { redirect_to admin_category_path(@admin_category), notice: "Categoría creada exitosamente." }
        format.json { render :show, status: :created, location: @admin_category }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @admin_category.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /admin/categories/1
  def update
    respond_to do |format|
      if @admin_category.update(admin_category_params)
        format.html { redirect_to admin_category_path(@admin_category), notice: "Categoría actualizada exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @admin_category }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @admin_category.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /admin/categories/1
  def destroy
    @admin_category.destroy!

    respond_to do |format|
      format.html { redirect_to admin_categories_path, notice: "Categoría eliminada exitosamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_admin_category
    @admin_category = Category.find(params[:id])
  end

  def admin_category_params
    params.require(:category).permit(:name, :description)
  end
end