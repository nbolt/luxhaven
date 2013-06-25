class BookingController < ApplicationController
  
  expose(:booking) { Booking.find params[:booking] }

  def index
  end

  def refund
    booking.refund!
  end

end
