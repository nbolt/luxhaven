class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
=begin
  before_filter do
    if user
      Analytics.identify(
        user_id: user.id, 
        traits: user.attributes
      )
    end
  end
=end
end

=begin
Analytics.track(
  user_id: user.id,
  event: 'Drank Milk',
  properties: { fat_content: 0.02, quantity: '4 gallons' }
)
=end