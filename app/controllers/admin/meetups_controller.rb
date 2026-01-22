class Admin::MeetupsController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :require_admin!

  def index
    @meetups = Meetup.ordered
  end

  def new
    @meetup = Meetup.new(number: Meetup.maximum(:number).to_i + 1, date: Date.current)
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
    params.require(:meetup).permit(:number, :date, :description)
  end
end
