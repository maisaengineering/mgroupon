class API::SessionsController < API::BaseController

  skip_before_filter :verify_authenticity_token#,only: :create#,  if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  #ref https://gist.github.com/jwo/1255275
  def create
    @user = User.api_find_for_fb_oauth(params)
    if @user.persisted?
      sign_in @user, store: false
      #send newly generated oauth_token(with 60 days validity)
      render status: 200,
             json: {success: true, info: "Logged in", oauth_token: @user.oauth_token,auth_token: @user.authentication_token,user_id: @user.id.to_s ,uid: @user.uid,full_name: @user.full_name}
      return
    else
      warden.custom_failure!
      render status: :unprocessable_entity,  json: { success: false,  errors: @user.errors.full_messages }
      return
    end
   failure
  end

  def destroy
    # expire auth token
    user = User.where(authentication_token: params[:auth_token]).first
    if user
      #user.reset_authentication_token!
      sign_out user
      # 204 renders nothing
      render  status: 200,json: {  success: true,info: 'Session deleted'}#,auth_token: user.authentication_token}
    else
      render  status: 404 ,json: { success: false, error: 'Invalid token.' }
    end
  end

  def failure
    render :status => :unauthorized,#401
           json: { success: false, error: "Login Failed"  }
  end

end
