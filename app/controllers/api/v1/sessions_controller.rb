module Api
  module V1
    class SessionsController < ActionController::API
      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          user.update!(auth_token: SecureRandom.hex(20))
          render json: { token: user.auth_token, user: { id: user.id, name: user.name, role: user.role } }
        else
          render json: { error: "Credenciales inválidas" }, status: :unauthorized
        end
      end

      def destroy
        header = request.headers["Authorization"]
        token = header&.split(" ")&.last
        user = User.find_by(auth_token: token) if token
        user&.update!(auth_token: nil)
        head :no_content
      end
    end
  end
end
