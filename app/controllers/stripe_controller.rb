class StripeController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def event
    case params[:type]
    when 'transfer.paid'
      booking = Booking.where(stripe_transfer_id: params[:data][:object][:id]).first
      booking.update_attribute :transfer_status, 'paid'
    when 'transfer.failed'
      booking = Booking.where(stripe_transfer_id: params[:data][:object][:id]).first
      booking.update_attribute :transfer_status, 'failed'
      # send an email
    end
    render status: 200, nothing: true
  end

end
