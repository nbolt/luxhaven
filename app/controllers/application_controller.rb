class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  expose(:region) { Region.friendly.find params[:region] }

  def features
    render json: Feature.all.as_json
  end

  def jregion
    json = Jbuilder.encode do |json|
      json.(region, :id, :name, :slug, :latitude, :longitude,
                    :attractions_description, :cafes_description, :nightlife_description, :shopping_description,
                    :getting_around, :description, :tagline
           )
      json.image region.image.url
      json.venues (JSON.parse region.venues.to_json(include: :venue)) # seems kind of weird but ok
    end
    render json: json
  end

  def enquire
    SendMail.new.async.perform UserMailer.enquire(current_user, params[:enquiry])
    render nothing: true
  end
end
