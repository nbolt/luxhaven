class AuthController < ApplicationController
  
  def signup
    user = User.new user_params
    if user.save
      auto_login user
      render 'signup-success'
    else
      err = user.errors.messages.first
      @err = "#{err[0]} #{err[1][0]}"
      user.destroy
      render 'signup-failure'
    end
  end

  def signin
    if login(params[:user][:email], params[:user][:password], true)
      render 'signin-success'
    else
      render 'signin-failure'
    end
  end

  def signout
    logout
    render json: { token: form_authenticity_token }
  end

  def auth
    render json: { success: logged_in?, user: current_user && current_user.to_json(include: :cards) }
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password, :password_confirmation)
  end
end
