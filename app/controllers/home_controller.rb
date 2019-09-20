class HomeController < ApplicationController
  def show
    @brigades = Brigade.all.order(:name)
  end
end
