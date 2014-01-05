class HiringController < ApplicationController

  def index
    render 'info/hiring'
  end

  def jobs
    render json: Job.active.as_json
  end

end
