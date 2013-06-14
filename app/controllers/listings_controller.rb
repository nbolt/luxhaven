class ListingsController < ApplicationController

  expose(:region) { Region.where(name: params[:city].gsub('_', ' ')).first }
  
  def search
    respond_to do |format|
      format.html
      format.json do
        listings = Listing.all
        listings = listings.where(property_type: params[:property_type].split(','))     if params[:property_type]
        listings = listings.where('price_per_night >= ?', params[:minPrice].to_i * 100) if params[:minPrice]
        listings = listings.where('price_per_night <= ?', params[:maxPrice].to_i * 100) if params[:maxPrice]
        listings = Listing.available params[:check_in], params[:check_out], listings    if params[:check_in] && params[:check_out]
        render json: listings
      end
    end
  end

end
