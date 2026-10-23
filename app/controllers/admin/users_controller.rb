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
      @user.role = role_param

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
      @user.assign_attributes(attrs)
      @user.role = role_param

      if @user.save
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
      params.require(:user).permit(:name, :email, :password)
    end

    # El rol se asigna aparte y solo si es uno de los valores válidos del enum
    def role_param
      role = params.dig(:user, :role)
      role if User.roles.key?(role)
    end
  end
end
