class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :first_name
  field :last_name
  field :provider
  field :uid
  field :oauth_token
  field :oauth_expires_at,type: Time

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Token authenticatable
  field :authentication_token, type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  #Validations
  validates :first_name, :last_name, presence: true


  # index(es) -------------------------------------------------------------------
  index({ uid: 1 }, {name: "user_uid_index" })# unique: true} )
  index({ provider: 1 })
  index({ authentication_token: 1})#, { unique: true} )

  # Callbacks -------------------------------------------------------------------
  before_save :ensure_authentication_token

  def self.find_for_facebook_oauth(auth)
    # immediately get 60 day auth token
    #oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
    #new_access_info = oauth.exchange_access_token_info auth.credentials.token
    #new_access_token = new_access_info["access_token"]
    #new_access_expires_at = DateTime.now + new_access_info["expires"].to_i.seconds
    user =  any_of({uid: auth.uid}, {email: auth.info.email}).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      # user.password = Devise.friendly_token[0,20]
      user.email = auth.info.email
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      # user.auth = auth
      #user.oauth_token = new_access_token
      #user.oauth_expires_at = new_access_expires_at
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
    user
  end


  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def reset_authentication_token!
    self.set(authentication_token: generate_authentication_token)
  end

  # email not required if singn-in via omniauth
  def email_required?
    super && provider.blank?
  end

  def password_required?
    super && provider.blank?
  end


  def full_name
    "#{self.first_name} #{self.last_name}"
  end


  private
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
