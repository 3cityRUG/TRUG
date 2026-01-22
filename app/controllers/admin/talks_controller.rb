class Admin::TalksController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :require_admin!
  before_action :set_meetup, only: [ :new, :create ]
  before_action :set_talk, only: [ :edit, :update, :destroy ]

  def new
    @talk = @meetup.talks.new
  end

  def create
    @talk = @meetup.talks.new(talk_params)
    if @talk.save
      redirect_to admin_meetups_path, notice: "Prezentacja została utworzona."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @talk.update(talk_params)
      redirect_to admin_meetups_path, notice: "Prezentacja została zaktualizowana."
    else
      render :edit
    end
  end

  def destroy
    @talk.destroy
    redirect_to admin_meetups_path, notice: "Prezentacja została usunięta."
  end

  private

  def set_meetup
    @meetup = Meetup.find(params[:meetup_id])
  end

  def set_talk
    @talk = Talk.find(params[:id])
  end

  def talk_params
    params.require(:talk).permit(:title, :speaker_name, :speaker_homepage, :slides_url, :source_code_url, :video_id, :video_provider, :video_thumb)
  end
end
