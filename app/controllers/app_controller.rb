class AppController < ApplicationController
  # before_action :authenticate_user!
  layout 'app'
  after_action :allow_iframe   #, only: []
  before_action :allow_all_cors #, only: []
  # skip_before_action :verify_authenticity_token
  # skip_before_action :verify_authenticity_token

  def index
    logger.debug "IN APP has current_user #{current_user.inspect}"

    unless current_user
      redirect_to "/app/login"
    end
  end

  # GET Login
  def login
    @secret = CLIENT_TOKEN_SALT
    @time = DateTime.now.to_s
    @token = Digest::SHA2.hexdigest @secret + "_" + @time
  end

  # POST login
  def new_login
    logger.debug "got login: #{params}"
    user = User.where(:email => params[:email]).first
    if user.blank? || !user.valid_password?(params[:password])
      redirect_to '/app/#login_failed'
    else
      sign_out(current_user) unless current_user.nil?
      sign_in(user)

      #if current_user.has_seen_intro
      redirect_to "/app/oefeningen/#{token}"
      #else
      #  redirect_to '/app/introductie'
      #end
    end
  end

  def forgot_password
    #user.send_reset_password_instructions
  end

  def test_api
    render json: {"var1"=>"abcdef", "var2"=>"ghijkl"}
  end

  # ----------------------------------------------------------------------------
  def oefeningen
    find_user_by_token
    @exercises = Exercise.where(:user_id => current_user.id)
  end

  def oefening
    @exercise = Exercise.find(params[:id])
  end

  def introductie
  end

  def info
  end

  def awards
  end

  def my_profile
  end

  # helper
  def autologintest
    #user = User.where(:email => "client@voicebuddy.com").first
    #sign_out(current_user) unless current_user.nil?
    #sign_in(user)
    #logger.debug "has current_user #{current_user.inspect}"
    redirect_to '/app/'
  end

  # helper
  def find_user_by_token
  end

  #def tokenrequest
    #generate token
    #time + hash
    #return time, hash
  #end

  #def authenticate_user
    #verify(token, time)
    #verify(user)
    #sign_in(user)
    #create token
    #save current_user
    #return token
  #end

  #def authenticate_user
    # user = User.where(:email => "client@voicebuddy.com").first
    # sign_out(current_user) unless current_user.nil?
    # sign_in(user)
  #end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def allow_all_cors
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, PUT, PATCH, POST, OPTIONS'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Access-Control-Allow-Headers'] = '*'
  end

end
