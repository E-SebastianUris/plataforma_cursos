module Api
  module V1
    class RegistrationsController < ActionController::API
      def create
        user = User.new(registration_params)
        user.role = :alumno
        if user.save
          user.update!(auth_token: SecureRandom.hex(20))
          render json: { token: user.auth_token, user: { id: user.id, name: user.name, role: user.role } }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def registration_params
        params.permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
