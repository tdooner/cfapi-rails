class BrigadeController < ApplicationController
  def show
    @brigade = Brigade.friendly.find(params[:id])
    @meetup_page = @brigade.meetup
    @projects = @brigade.brigade_projects
  end
end
