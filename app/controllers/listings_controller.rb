class ListingsController < ApplicationController

  expose(:region) { Region.friendly.find params[:city] }
  expose(:listing) do
    region = Region.friendly.find params[:city]
    Listing.where(region_id: region.id).friendly.find params[:listing_title]
  end
  
  def search
    expires_in 1.hour, public: true
    respond_to do |format|
      format.html
      format.json do
        listings = Listing.all
        listings = listings.where(property_type: params[:property_type].split(','))     if params[:property_type]
        listings = listings.where('price_per_night >= ?', params[:minPrice].to_i * 100) if params[:minPrice]
        listings = listings.where('price_per_night <= ?', params[:maxPrice].to_i * 100) if params[:maxPrice]
        listings = Listing.available params[:check_in], params[:check_out], listings    if params[:check_in] && params[:check_out]
        render json: listings.to_json(include: :bookings)
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: listing.to_json(include: :bookings)
      end
    end
  end

  def book
    booking = Booking.new
    booking.listing = listing
    booking.user = current_user
    booking.check_in = params[:check_in]
    booking.check_out = params[:check_out]
    booking.price_period = 'night'
    booking.card = params[:card]
    case params[:card][0..2]
    when 'cus' then booking.card_type = 'customer'
    when 'tok' then booking.card_type = 'card'
    end
    if booking.save
      rsp = booking.book!
      if rsp.class == Stripe::Charge
        render json: { success: true }
      else
        render json: { success: false }
      end
    else
      render json: { success: false }
    end
  end

end
