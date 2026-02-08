class Admin::MeetupsController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :require_admin!

  def index
    @meetups = Meetup.ordered.includes(:talks)
    @meetups = @meetups.where(event_type: params[:type]) if params[:type].present?
    @total_meetups = Meetup.count
    @upcoming_meetups = Meetup.upcoming.count
    @total_talks = Talk.count
    @average_talks_per_meetup = @total_meetups > 0 ? (@total_talks.to_f / @total_meetups).round(1) : 0
  end

  def show
    @meetup = Meetup.includes(:talks).find(params[:id])
  end

  def new
    event_type = params[:type] || "formal"
    attributes = { date: Date.current, event_type: event_type }

    # Only set default number for formal meetups, not for bar events
    if event_type == "formal"
      attributes[:number] = Meetup.formal.maximum(:number).to_i + 1
    end

    @meetup = Meetup.new(attributes)
  end

  def create
    @meetup = Meetup.new(meetup_params)
    if @meetup.save
      redirect_to admin_meetups_path, notice: "Spotkanie zostało utworzone."
    else
      render :new
    end
  end

  def edit
    @meetup = Meetup.find(params[:id])
  end

  def update
    @meetup = Meetup.find(params[:id])
    if @meetup.update(meetup_params)
      redirect_to admin_meetups_path, notice: "Spotkanie zostało zaktualizowane."
    else
      render :edit
    end
  end

  def destroy
    @meetup = Meetup.find(params[:id])
    @meetup.destroy
    redirect_to admin_meetups_path, notice: "Spotkanie zostało usunięte."
  end

  private

  def meetup_params
    params.require(:meetup).permit(:number, :date, :description, :location, :event_type)
  end
end
