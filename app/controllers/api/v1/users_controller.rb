module Api
  module V1
    class UsersController < BaseController
      def profile
        render json: { id: current_user.id, name: current_user.name, email: current_user.email, role: current_user.role }
      end

      def update
        if current_user.update(profile_params)
          render json: { id: current_user.id, name: current_user.name, email: current_user.email, role: current_user.role }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
