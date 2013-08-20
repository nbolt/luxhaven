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

  def forgot    
    user = User.where(email: params[:email]).first
    if user
      UserMailer.forgot(user).deliver!
      render 'forgot-success'
    else
      render 'forgot-failure'
    end
  end

  def reset
    user = User.where(reset_password_token: params[:token]).first
    user.change_password! params[:password]
    auto_login user
    render 'reset-success'
  end

  def check
    user = User.where(reset_password_token: params[:token]).first
    render json: { success: user && true || false }
  end

  def auth
    render json: { success: logged_in?, user: current_user && current_user.to_json(include: :cards) }
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password, :password_confirmation)
  end
end
