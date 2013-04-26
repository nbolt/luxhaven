class AuthController < ApplicationController
  
  def signup
    user = User.new
    user.save
  end

  def login
    login(user, password, true)
  end

  def logout
    logout
  end

end
