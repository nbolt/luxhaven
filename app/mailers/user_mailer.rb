class UserMailer < ActionMailer::Base

  def reset_password
  end

  def booked booking
    @booking = booking
    mail(subject: 'Your LuxHaven Booking', to: booking.user.email, from: 'hello@luxhaven.co')
  end

  def forgot user
    @user = user
    token = nil
    loop do
      token = rand(36**12).to_s 36
      break unless User.where(reset_password_token: token).first
    end
    user.update_attribute :reset_password_token, token
    mail(subject: 'LuxHaven - Reset Your Password', to: user.email, from: 'hello@luxhaven.co')
  end

end