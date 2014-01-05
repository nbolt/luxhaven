class FaqController < ApplicationController

  def index
    @tab = 'faq'
    render 'info/faq'
  end

  def faqs
    render json: FaqSection.all.as_json(include: { faq_topics: { include: :faqs } })
  end

end
