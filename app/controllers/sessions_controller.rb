class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password]) && user.admin?
      session[:user_id] = user.id
      redirect_to admin_root_path, notice: "Bienvenido, #{user.name}"
    else
      flash.now[:alert] = "Email, contraseña incorrectos o sin permisos de administrador"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Sesión cerrada"
  end
end
