module Admin
  class ReviewsController < BaseController
    def index
      @reviews = Review.includes(:user, :course).order(created_at: :desc)
    end

    def destroy
      Review.find(params[:id]).destroy
      redirect_to admin_reviews_path, notice: "Reseña eliminada"
    end
  end
end
