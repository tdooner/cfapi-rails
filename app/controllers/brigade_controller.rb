class BrigadeController < ApplicationController
  def show
    @brigade = Brigade.find_by(name: params[:id])
    @meetup_page = @brigade.meetup
    @projects = @brigade.brigade_projects
  end
end
