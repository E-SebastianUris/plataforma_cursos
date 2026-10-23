module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[edit update destroy]

    def index
      @users = User.order(:role, :name)
    end

    def new
      @user = User.new(role: :profesor)
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "Usuario creado"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      attrs = user_params
      attrs = attrs.except(:password) if attrs[:password].blank?

      if @user.update(attrs)
        redirect_to admin_users_path, notice: "Usuario actualizado"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "No podés eliminar tu propio usuario"
      else
        @user.destroy
        redirect_to admin_users_path, notice: "Usuario eliminado"
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :role)
    end
  end
end