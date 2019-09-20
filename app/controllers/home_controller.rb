class HomeController < ApplicationController
  def show
    @brigades = Brigade.all
  end
end
