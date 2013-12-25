class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  expose(:region) { Region.friendly.find params[:region] }

  def features
    render json: Feature.all.as_json
  end

  def jregion
    render json: region.to_json(include: {venues: {include: :address}})
  end

  def enquire
    SendMail.new.async.perform UserMailer.enquire(current_user, params[:enquiry])
    render nothing: true
  end
end
