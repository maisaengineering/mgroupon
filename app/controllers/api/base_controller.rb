class API::BaseController < ApplicationController
  #skip_before_filter :require_ssl

  after_filter :cors_set_access_control_headers
  before_filter :authenticate_user_from_token! # it is empty hook provided by devise i,e
  # once user is successfully authenticated with the token devise look for this method ,
  # and execute the code there

  skip_before_filter :verify_authenticity_token#, :if => Proc.new { |c| c.request.format == 'application/json' }

  helper_method :latitude,:longitude,:friend?

  # respond to options requests with blank text/plain as per spec
  def cors_preflight_check
    logger.info ">>> responding to CORS request"
    render :text => '', :content_type => 'text/plain'
  end

  def latitude
    @latitude = params[:lat] || nil
  end

  def longitude
    @longitude = params[:long] || nil
  end

  def find_friends
    @c_user_friends = current_user ? current_user.friends : []
    @friend_ids = @c_user_friends.map(&:id)
  end

  def friend?(id)
    @friend_ids.include?(id)
  end


  # For all responses in this controller, return the CORS access control headers.
  # Ref http://stackoverflow.com/questions/17308570/ember-app-requests-to-rails-app-cross-domain
  # match '/*path' => 'application#cors_preflight_check', :via => :options
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'X-AUTH-TOKEN, X-API-VERSION, X-Requested-With, Content-Type, Accept, Origin'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  private

  def has_required_params?(*keys)
    if keys.all? {|key| params[key] }
      true
    else
      missing_params = keys.select {|key| !params[key] }
      str = missing_params.size > 1 ? 'params' : 'param'
      render :text => "Request is missing #{str} #{missing_params.map(&:inspect).to_sentence}",
             :status => :bad_request
      false
    end
  end

  def user_not_authorized
    render status: :unauthorized,#:forbidden
           json: { success: false, info: t('pundit.access_denied')}
  end
  # For this example, we are simply using token authentication
  # authentication features to get the token from a header.
  #TODO use this for token_authentication https://github.com/baschtl/devise-token_authenticatable
  def authenticate_user_from_token!
    user_token = params[:auth_token].presence
    if user_token
      user =  User.where(authentication_token: user_token.to_s).first
      if user
        # Notice we are passing store false, so the user is not
        # actually stored in the session and a token is needed
        # for every request. If you want the token to work as a
        # sign in token, you can simply remove store: false.
        sign_in user, store: false
      else
        render status: 401,  json: {success: false, error: "invalid token" }
      end
    end
  end

end