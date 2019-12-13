class BrigadeController < ApplicationController
  def show
    @brigade = Brigade.find_by(name: params[:id])

    if @brigade.meetup_urlname
      @meetup_page = ApiObject::MeetupGroup.with_meetup_urlname(@brigade.meetup_urlname).first
    end
  end
end
