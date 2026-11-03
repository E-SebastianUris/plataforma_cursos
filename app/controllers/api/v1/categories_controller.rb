module Api
  module V1
    class CategoriesController < ActionController::API
      def index
        render json: Category.order(:name).as_json(only: [ :id, :name ])
      end
    end
  end
end
