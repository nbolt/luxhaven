class HiringController < ApplicationController

  def index
    render 'info/hiring'
  end

  def jobs
    render json: Job.active.as_json(include: [:about_qualifications, :skill_qualifications, :responsibility_qualifications])
  end

end
