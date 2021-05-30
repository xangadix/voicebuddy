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

    if params[:token]
      #{@token}
      user = User.where(:authorisation_token => params[:token])
      unless user.blank?
        redirect_to "/app/oefeningen/#{params[:token]}"
        return
      end
    end

    unless current_user
      redirect_to "/app/login"
      return
    end
  end

  # GET Login
  def login

    if params[:token]
      #{@token}
      unless user.blank?
        redirect_to "/app/oefeningen/#{params[:token]}"
        return
      end
    end

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

    if current_user.nil?
      redirect_to "/app"
      return
    end

    @exercises = Exercise.where(:user_id => current_user.id, :claimed_award => false)

    all_completed = true
    @exercises.each do |ex|

      # checks if the streak needs resetting
      logger.debug("check streak reset #{ex.last_progress_update} #{ex.last_progress_update < DateTime.now.beginning_of_day - 1.day}")
      days_ago = ( DateTime.now - ex.last_progress_update.beginning_of_day ).to_i
      # it has been more then a day that the user did this exercise
      # invladiate the streak!

      # validates the exercise
      ex.validate

      # validates if all are completed for the day
      unless ex.completed_for_the_day || ex.completed
        all_completed = false
      end

    end


    #logger.debug "streak days ago is #{days_ago}"
    #if  days_ago > 1
    #  logger.debug "INVALIDATE streak!"
    #  current_user.streak = 0
    #  current_user.last_streak_update = DateTime.now
      # were still in the streak if all completed is true
    #end

    # assigns an extra point to the streak, when all exercises are done for the day
    # (and sets streaks last update is 1 day old!
    # if all_completed && (current_user.last_streak_update > DateTime.now.beginning_of_day - 1.day) # <<<--- klopt dit wel?
    logger.debug "completed? #{all_completed} last update #{current_user.last_streak_update} > #{DateTime.now.beginning_of_day - 1.day}"

    # && (current_user.last_streak_update > DateTime.now.beginning_of_day - 1.day)
    if all_completed && !current_user.streak_lock
      @streak_update = true
      current_user.streak = current_user.streak += 1
      current_user.streak_lock = true
      # current_user.last_streak_update = DateTime.now # should be LAST streak update?
    elsif !all_completed
      current_user.streak_lock = false
    end

    # sets streak to complete, and shows claim-streak button (?)
    if current_user.streak >= current_user.streak_target # && !current_user.streak_lock
      @streak_complete = true
    end

    # just in case, save current user (and the streak)
    current_user.save()

    # return the exercies
    return @exercises
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

    # ?!
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
    @exercises = Exercise.where(:user_id => current_user.id, :claimed_award => true)
  end

  def claim_reward
    @token = params[:token]
    if @token.nil?
      render plain: "Kon de gebruiker niet verifieren. Dit betekend dat niet langer zeker is dat de juiste gebruiker de app gebruikt. Herstart de app helemaal en log opnieuw in"
      return
    end
    @exercise = Exercise.find(params[:id])
    logger.debug "-----------------------------------------got token: #{params} got score #{@exercise.achieved_array.sum.to_f / @exercise.achieved_array.count.to_f}"
    # logger.debug "hello?"
    user = find_user_by_token(@token)
    @exercise.claimed_award = true
    @exercise.score = ( @exercise.achieved_array.sum.to_f / @exercise.achieved_array.count.to_f ) * 1000

    @exercise.save
  end

  def claim_streak
    @token = params[:token]
    logger.debug("GOT TOKEN #{@token}")
    find_user_by_token(params[:token])
    current_user.claimed_streaks = current_user.claimed_streaks + 1

    # reset streak
    current_user.streak = 0
    current_user.streak_lock = false

    #render plain: current_user.to_json
    #redirect_to "app/oefeningen"
    current_user.save
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
    if _token.nil? || user.nil?
    else
      sign_out(current_user) unless current_user.nil?
      sign_in(user)
    end

    sign_in(user) unless current_user.nil?
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
