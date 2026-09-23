module Api
  module V1
    class UsersController < BaseController
      def profile
        render json: { id: current_user.id, name: current_user.name, email: current_user.email, role: current_user.role }
      end
    end
  end
end
