class UserMailer < ActionMailer::Base

  def reset_password
  end

  def booked booking
    @booking = booking
    mail(subject: 'Your LuxHaven Booking', to: booking.user.email, from: 'hello@luxhaven.co')
  end

end