class AnalyticsEvent
  include SuckerPunch::Job

  def perform(user, event, properties={})
    Analytics.track(
      user_id: user.id,
      event: event,
      properties: properties
    )
  end
end