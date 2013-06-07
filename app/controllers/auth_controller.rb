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
    render nothing: true
  end

  def auth
    render json: { success: logged_in? }
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password, :password_confirmation)
  end
end
