class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :listing

  validate :conflicts

  scope :charged, -> { where(payment_status: 'charged') }

  def conflicts
    errors.add :booking, 'Conflicts with another booking' if listing.conflicts? check_in, check_out
  end

  def price_total
    nights = (check_out - check_in).to_i
    case price_period
    when 'night'
      listing.price_per_night * nights
    when 'week'
      listing.price_per_week  * (nights / 7)
    when 'month'
      listing.price_per_month * (nights / 30.0).round
    end
  end

  def book!
    begin
      raise BookingError, "Booking ##{id} has already been processed." if payment_status
      rsp = Stripe::Charge.create(
        amount: price_total,
        currency: 'usd',
        description: id,
        customer: customer_id
      )
      update_attributes payment_status: 'charged', stripe_charge_id: rsp.id
      UserMailer.booked(self).deliver!
      return rsp
    rescue Stripe::CardError => err
      return err
    rescue Stripe::InvalidRequestError => err
      return err
    rescue Stripe::StripeError => err
      return err
    rescue BookingError => err
      return err
    end
  end

  def refund!
    Stripe::Charge.retrieve(stripe_charge_id).refund
    update_attribute :payment_status, 'refunded'
  end

  def transfer!
    begin
      case transfer_status
      when 'pending'
        raise BookingError, "The transfer for booking ##{id} is already pending."
      when 'paid'
        raise BookingError, "The transfer for booking ##{id} has already been paid."
      when 'failed'
        raise BookingError, "The transfer for booking ##{id} has failed. Try again when this status is lifted."
      end
      if Date.today > check_out && listing.user.stripe_recipient
        rsp = Stripe::Transfer.create(
          amount: price_total,
          currency: 'usd',
          recipient: listing.user.stripe_recipient,
          description: id,
          statement_descriptor: id
        )
        update_attributes transfer_status: 'pending', stripe_transfer_id: rsp.id
        return rsp
      elsif !listing.user.stripe_recipient
        raise BookingError, "The host for booking ##{id} has not entered their bank details."
      else
        raise BookingError, "The check out date for booking ##{id} has not transpired."
      end
    rescue BookingError => err
      return err
    end
  end
end
