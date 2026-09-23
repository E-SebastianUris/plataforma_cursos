module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_user!

      private

      def authenticate_user!
        header = request.headers["Authorization"]
        token = header&.split(" ")&.last
        @current_user = User.find_by(auth_token: token) if token

        render json: { error: "No autorizado" }, status: :unauthorized unless @current_user
      end

      def current_user
        @current_user
      end
    end
  end
end
