class BrigadeController < ApplicationController
  before_action :set_brigade
  before_action :can_edit_brigade, only: %i[edit add_leader]

  def show
    @meetup_page = @brigade.meetup
    @projects = @brigade.brigade_projects
  end

  def edit
  end

  def add_leader
    new_brigade_leader = BrigadeLeader.create(
      brigade_leader_params.merge(
        brigade: @brigade
      )
    )

    if new_brigade_leader
      flash[:info] = 'Successfully added Brigade Leader'
    else
      flash[:error] = 'Error adding Brigade leader'
    end

    redirect_to edit_brigade_path(@brigade)
  end

  private

  def set_brigade
    @brigade = Brigade.friendly.find(params.fetch(:id, params[:brigade_id]))
  end

  def can_edit_brigade
    return redirect_to root_url unless current_user.present?

    unless current_user.can_manage_brigade?(@brigade)
      return redirect_to root_url, flash: { error: "You don't have permission to edit this Brigade." }
    end
  end

  def brigade_leader_params
    params
      .fetch(:brigade_leader, {})
      .permit(:name, :email)
  end
end
