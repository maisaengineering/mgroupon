class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :location,:latitude,:longitude
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    #flash[:error] = t('pundit.access_denied')
    # render file: "public/401.html", status: :unauthorized
    render 'shared/access_denied'
    #redirect_to(request.referrer || root_path)
  end

  def latitude
    @latitude = session[:geo].try(:fetch, :lat, nil)
  end

  def longitude
    @longitude = session[:geo].try(:fetch, :long, nil)
  end

end
