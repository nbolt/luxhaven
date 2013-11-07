class ListingsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  expose(:region) { Region.friendly.find params[:city] }
  expose(:region_listings) { Listing.where(region_id: region.id) }
  expose(:listing) do
    region = Region.friendly.find params[:city]
    region_listings.friendly.find params[:listing_slug]
  end

  before_filter :admin, only: [:manage, :update, :create]
  
  def search
    expires_in 1.hour, public: true

    response.headers['Vary'] = 'Accept'
    respond_to do |format|
      format.html
      format.json do
        listings = region_listings.where 'user_id is not null'
        listings = listings.where(property_type: params[:property_type].split(','))     if params[:property_type]
        ['garden', 'balcony', 'smoking', 'pets', 'children', 'babies', 'toddlers', 'tv',
         'temp_control', 'pool', 'jacuzzi', 'washer']
          .each do |amenity|
            listings = listings.where("#{amenity} is #{params[amenity]}") if params[amenity]
          end
        listings = listings.where('parking > 0') if params[:parking]
        listings = listings.where('price_per_night >= ?', params[:minPrice].to_i * 100) if params[:minPrice]
        listings = listings.where('price_per_night <= ?', params[:maxPrice].to_i * 100) if params[:maxPrice]
        listings = listings.where('sleeps >= ?', params[:sleeps]) if params[:sleeps]
        listings = listings.where('bedrooms >= ?', params[:beds]) if params[:beds]
        listings = listings.where(district_id: params[:district]) unless params[:district] == '0'
        listings = listings.send params[:sort]
        listings = Listing.available params[:check_in], params[:check_out], listings if params[:check_in] && params[:check_out]
        paginated_listings = Kaminari.paginate_array(listings).page(params[:page]).per 5
        render json: { size: listings.size, listings: paginated_listings.as_json(include: [:bookings, :address, :paragraphs]) }
      end
    end
  end

  def show
    response.headers['Vary'] = 'Accept'
    respond_to do |format|
      format.html
      format.json do
        render json: listing.to_json(
          include: {
            images: nil,
            bookings: nil,
            features: nil,
            address: { include: :region },
            paragraphs: { include: :image },
            rooms: { include: [:features, :images] }
          }
        )
      end
    end
  end

  def pricing
    booking = Booking.new
    booking.listing = listing
    booking.check_in = Time.at params[:check_in].to_i
    booking.check_out = Time.at params[:check_out].to_i
    render json: { total: number_with_delimiter(booking.price_total / 100) }
  end

  def book
    booking = Booking.new
    booking.listing = listing
    booking.user = current_user
    booking.check_in = Date.strptime params[:check_in], '%m/%d/%Y'
    booking.check_out = Date.strptime params[:check_out], '%m/%d/%Y'
    if params[:card][0..2] == 'cus'
      booking.customer_id = params[:card]
    else
      customer = Stripe::Customer.create(email: current_user.email, card: params[:card])
      booking.customer_id = customer.id
      card = current_user.cards.build({
        stripe_id: customer.id,
        last4: customer.active_card.last4,
        card_type: customer.active_card.type.downcase.gsub(' ', '_'),
        fingerprint: customer.active_card.fingerprint
      })
      card.save
      current_user.cards.sort_by(&:created_at).first.destroy if current_user.cards.count > 3
    end
    if booking.save
      rsp = booking.book!
      if rsp.class == Stripe::Charge
        render json: { success: true, charge: rsp }
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
    render json: { url: "http://#{request.domain}:#{request.port}/#{listing.slugs}" }
  end

  def create
    listing = Listing.new(title: 'New Listing')
    listing.address = Address.create
    listing.address.region = Region.first
    listing.save
    render json: { url: "http://#{request.domain}:#{request.port}/#{listing.slugs}" }
  end

  def admin
    redirect_to '/' unless current_user && current_user.admin
  end

end
