class AppController < ApplicationController
  # before_action :authenticate_user!
  layout 'app'
  after_action :allow_iframe   #, only: []
  before_action :allow_all_cors #, only: []
  # skip_before_action :verify_authenticity_token
  # skip_before_action :verify_authenticity_token
  # before_action except: [:index, :login, :new_login, :forgot_password]

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
      redirect_to '/app/login_failed'

    else
      sign_out(current_user) unless current_user.nil?
      sign_in(user)

      # this also saves the token!
      user_token = current_user.set_authorisation_token

      if current_user.has_seen_intro
        redirect_to "/app/oefeningen/#{user_token}"
      else
        redirect_to "/app/introductie/#{user_token}"
      end
    end
  end

  def login_failed
    @secret = CLIENT_TOKEN_SALT
    @time = DateTime.now.to_s
    @token = Digest::SHA2.hexdigest @secret + "_" + @time
    @login_failed = "Login is niet gelukt"
    render "app/login"
  end

  def forgot_password
    #user.send_reset_password_instructions
  end

  # depricated
  def test_api
    render json: {"var1"=>"abcdef", "var2"=>"ghijkl"}
  end

  # ----------------------------------------------------------------------------
  def oefeningen
    @token = params[:token]
    logger.debug("GOT TOKEN #{@token}")
    find_user_by_token(params[:token])

    current_user.exercises.each do |ex|
      ex.validate_streak
    end

    @exercises = Exercise.where(:user_id => current_user.id)
  end

  def oefening
    @token = params[:token]
    logger.debug("GOT TOKEN #{@token}")
    if @token == "logo_128_touch_icon"
      render plain: "0"
      return
    end
    find_user_by_token(params[:token])
    @exercise = Exercise.find(params[:id])
  end

  def introductie
    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)

    current_user.has_seen_intro = true
    current_user.save
    @user = user
  end

  def info
    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)
  end

  def awards
    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)
  end

  def my_profile
    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)
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
  def find_user_by_token(_token)
    unless current_user.nil?
      return current_user
    end

    logger.debug "find user by token #{_token}"
    user = User.where(:authorisation_token => _token).first
    sign_out(current_user) unless current_user.nil?
    sign_in(user)

    if _token.nil? || user.nil?
      redirect_to "/app"
      return
    end

    sign_in(user)
    return user
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

  # cookieless authorisation scheme
  #def check_user
  #  if current_user.nil? && params[:token].nil?
  #    redirect_to '/app/'
  #    return
  #  elsif current_user.nil?
  #    user = User.where(:latest_token => params[:token]).first
  #    if user.nil?
  #      redirect_to '/app/'
  #      return
  #    else
  #      sign_in(user)
  #    end
  #  end
  #end

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
