class ListingsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  expose(:region) { Region.friendly.find params[:city] }
  expose(:listing) do
    region = Region.friendly.find params[:city]
    Listing.where(region_id: region.id).friendly.find params[:listing_slug]
  end

  before_filter :admin, only: [:manage, :update, :create]
  
  def search
    expires_in 1.hour, public: true

    response.headers['Vary'] = 'Accept'
    respond_to do |format|
      format.html
      format.json do
        listings = Listing.all
        listings = listings.where(property_type: params[:property_type].split(','))     if params[:property_type]
        listings = listings.where('price_per_night >= ?', params[:minPrice].to_i * 100) if params[:minPrice]
        listings = listings.where('price_per_night <= ?', params[:maxPrice].to_i * 100) if params[:maxPrice]
        listings = Listing.available params[:check_in], params[:check_out], listings rescue nil if params[:check_in] && params[:check_out]
        listings = listings.send params[:sort]
        listings = Kaminari.paginate_array(listings).page(params[:page]).per 5
        render json: { size: listings.size, listings: listings.as_json(include: [:bookings, :address]) }
      end
    end
  end

  def show
    response.headers['Vary'] = 'Accept'
    respond_to do |format|
      format.html
      format.json do
        render json: listing.to_json(include: [:address, :bookings])
      end
    end
  end

  def pricing
    booking = Booking.new
    booking.listing = listing
    booking.check_in = params[:check_in]
    booking.check_out = params[:check_out]
    render json: { total: number_with_delimiter(booking.price_total / 100) }
  end

  def book
    booking = Booking.new
    booking.listing = listing
    booking.user = current_user
    booking.check_in = params[:check_in]
    booking.check_out = params[:check_out]
    case params[:card][0..2]
    when 'cus' then booking.customer_id = params[:card]
    when 'tok'
      customer = Stripe::Customer.create(email: current_user.email, card: params[:card])
      booking.customer_id = customer.id
      card = current_user.cards.create({
        stripe_id: customer.id,
        last4: customer.active_card.last4,
        card_type: customer.active_card.type.downcase.gsub(' ', '_'),
        fingerprint: customer.active_card.fingerprint
      })
      current_user.cards.sort_by(&:created_at).first.destroy if current_user.cards.count > 3
    end
    if booking.save
      rsp = booking.book!
      if rsp.class == Stripe::Charge
        render json: { success: true, stripe_id: rsp.id }
      else
        capture_exception rsp
        render json: { success: false, error: rsp.message }
      end
    else
      capture_message booking.errors.messages.first[1][0]
      render json: { success: false, error: booking.errors.messages.first[1][0] }
    end
  end

  def update
    JSON.parse(request.body.read)['listing_updates'].each do |attr, value|
      if value.class == Hash
        case attr
        when 'address'
          address = listing.address
          value.each {|attr, value| address[attr] = value}
          address.save
        end
      else
        listing[attr] = value
      end
    end
    listing.save
    render nothing: true
  end

  def create
  end

  def admin
    redirect_to '/' unless current_user && current_user.is_admin?
  end

end
