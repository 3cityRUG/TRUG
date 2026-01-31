class AttendancesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_meetup

  def new
    @meetup = Meetup.upcoming.first
    @attendance = Attendance.new
    @submit_url = auth_provider_path(:github)
  end

  def create
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
      respond_to do |format|
        format.html do
          if turbo_frame_request?
            @next_meetup = @meetup
            render inline: "<%= turbo_frame_tag 'attendance_section' do %><%= render partial: 'pages/attendance_section' %><% end %>"
          else
            redirect_to root_path, notice: "Dziękujemy! Twój udział został zarejestrowany."
          end
        end
      end
    else
      redirect_to root_path, alert: "Wystąpił błąd. Spróbuj ponownie."
    end
  end

  private

  def set_meetup
    @meetup = Meetup.ordered.first
    render plain: "Not Found", status: :not_found unless @meetup
  end
end
