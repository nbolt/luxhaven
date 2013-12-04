class UserMailer < ActionMailer::Base

  def booked booking
    @booking = booking
    mail(subject: 'Your Luxhaven Booking', to: booking.user.email, from: 'hello@luxhaven.co')
  end

  def forgot user
    @user = user
    token = nil
    loop do
      token = rand(36**12).to_s 36
      break unless User.where(reset_password_token: token).first
    end
    user.update_attribute :reset_password_token, token
    mail(subject: 'Luxhaven - Reset Your Password', to: user.email, from: 'hello@luxhaven.co')
  end

  def enquire(user, enquiry)
    @enquiry = enquiry
    @user = user
    mail(subject: "An enquiry from #{user.name}", to: 'c@chrisbolton.me', from: 'hello@luxhaven.co', reply_to: user.email)
  end

end