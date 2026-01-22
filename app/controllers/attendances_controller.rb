class AttendancesController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  before_action :set_meetup, only: [ :new, :create ]

  def new
    if !authenticated?
      session[:attendance_meetup_id] = @meetup.id
      session[:attendance_status] = params[:status]
      redirect_to auth_provider_path(:github)
      return
    end

    github_username = current_user.github_username
    status = (params[:status] || session[:attendance_status] || 1).to_i

    if github_username.blank?
      redirect_to root_path, alert: "Nie znaleziono Twojego profilu GitHub."
      return
    end

    attendance = Attendance.find_or_initialize_by(
      meetup: @meetup,
      github_username: github_username
    )
    attendance.status = status

    if attendance.save
      session.delete(:attendance_meetup_id)
      session.delete(:attendance_status)
      redirect_to root_path, notice: "Dziękujemy! Twój udział został zarejestrowany."
    else
      redirect_to root_path, alert: "Wystąpił błąd. Spróbuj ponownie."
    end
  end

  def create
    if !authenticated?
      session[:attendance_meetup_id] = @meetup.id
      session[:attendance_status] = params[:status]
      redirect_to auth_provider_path(:github)
      return
    end

    github_username = current_user.github_username
    status = (params[:status] || 1).to_i

    attendance = Attendance.find_or_initialize_by(
      meetup: @meetup,
      github_username: github_username
    )
    attendance.status = status

    if attendance.save
      redirect_to root_path, notice: "Dziękujemy! Twój udział został zarejestrowany."
    else
      redirect_to root_path, alert: "Wystąpił błąd. Spróbuj ponownie."
    end
  end

  private

  def set_meetup
    @meetup = Meetup.ordered.first
  end
end
