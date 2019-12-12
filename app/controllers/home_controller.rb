class HomeController < ApplicationController
  def show
    @brigades = Brigade.all.order(:name).includes(:brigade_leaders, :brigade_projects)
  end
end
