class AppController < ApplicationController
  # before_action :authenticate_user!
  layout 'app'
  after_action :allow_iframe   #, only: []
  before_action :allow_all_cors #, only: []
  before_action :check_device
  # skip_before_action :verify_authenticity_token
  # skip_before_action :verify_authenticity_token
  # before_action except: [:index, :login, :new_login, :forgot_password]
   respond_to :js, :html

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
    @title = "User Login"
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
    @login_failed = "Login niet gelukt; controleer uw email adres en wachtwoord."
    render "app/login"
  end

  # forgot and update password
  def forgot_password
    #user.send_reset_password_instructions
    resource = User.new
  end

  # POST /resource/password
  def create_password
    @user = User.where(:email=>params[:user][:email]).first
    @user.send_reset_password_instructions
    #yield resource if block_given?

    #if successfully_sent?(resource)
    #  respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    #else
    #  respond_with(resource)
    #end
    #render plain: "instructies komen er aan! \n\n #{@user.to_yaml}"
    redirect_to "/app/password/sent"
  end

  def edit_password
    resource = User.find(params[:user_id] || @user_id)
    @user = User.find(params[:user_id] || @user_id)
    #set_minimum_password_length
    logger.debug "has user: #{@user.inspect}"
    #@user.reset_password_token = raw(params[:reset_password_token] || @reset_password_token)

    render "forgot_password_edit"
  end

  # patch, put
  def update_password
    resource = User.reset_password_by_token(params[:user]||@user)
    resource_name = "User"
    yield resource if block_given?

    if resource.errors.empty?
      redirect_to "/app/login", notice: "wachtwoord is ingesteld"
    else
      #set_flash_message!(:notice, :updated_not_active)
      #render "forgot_password_edit"
      logger.debug "---"
      logger.debug resource.reset_password_token
      logger.debug "---"

      @user = resource
      @resource = resource
      @reset_password_token = params[:reset_password_token]
      @user_id = resource.id.to_s
      @errors = resource.errors

      @token1 = resource.reset_password_token
      @token2 = params[:reset_password_token]
      @user.reset_password_token = params[:reset_password_token]

      render "forgot_password_edit"
      #redirect_to "/app/password/edit/60dada11a19ea6d60b30b293?reset_password_token=RUzGDC1UapeF1R6G4bzZ"
    end

    #if resource.errors.empty?
    #  resource.unlock_access! if unlockable?(resource)
    #  if Devise.sign_in_after_reset_password
    #    flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
    #    set_flash_message!(:notice, flash_message)
    #    resource.after_database_authentication
    #    sign_in(resource_name, resource)
    #  else
    #    set_flash_message!(:notice, :updated_not_active)
    #  end
    #  respond_with resource, location: after_resetting_password_path_for(resource)
    #else
    #  #set_minimum_password_length
    #  respond_with resource
    #end
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

    # title
    @title = "Oefeningen voor #{@current_user.full_name}"

    # get "ACTIVE" exercises
    @exercises = Exercise.where(:user_id => current_user.id, :claimed_award => false)

    # define all complete
    all_completed = true

    # start check
    @exercises.each do |ex|

      # checks if the streak needs resetting
      logger.debug("check streak reset #{ex.last_progress_update} #{ex.last_progress_update < DateTime.now.beginning_of_day - 1.day}")
      days_ago = ( DateTime.now - ex.last_progress_update.beginning_of_day ).to_i
      # it has been more then a day that the user did this exercise
      # invladiate the streak!

      # validates the exercise (against todays date)
      ex.validate

      # validates if ALL are completed for the day
      unless ex.completed_for_the_day || ex.completed
        all_completed = false
      end

    end

    # this is now handled in claim_streak
    #logger.debug "streak days ago is #{days_ago}"
    # if  (DateTime.now.to_i - current_user.last_streak_update.to_i) > 2.day
    #  logger.debug "INVALIDATE streak!"
    #  current_user.streak = 0
    #  current_user.last_streak_update = DateTime.now
    #  were still in the streak if all completed is true
    # end

    # assigns an extra point to the streak, when all exercises are done for the day
    # (and sets streaks last update is 1 day old!
    # if all_completed && (current_user.last_streak_update > DateTime.now.beginning_of_day - 1.day) # <<<--- klopt dit wel?
    logger.debug "completed? #{all_completed} last update #{current_user.last_streak_update} > #{DateTime.now.beginning_of_day - 1.day}"

    # && (current_user.last_streak_update > DateTime.now.beginning_of_day - 1.day)
    if all_completed && !current_user.streak_lock && @exercises.count > 0
      @streak_update = true
      current_user.streak = current_user.streak += 1
      current_user.streak_lock = true
      current_user.last_streak_update = DateTime.now # should be LAST streak update?
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
    @title = "Introductie voor #{@current_user.full_name}"

    # ?!
    @user = user
  end

  def info
    if params[:token] == "logo_128_touch_icon"
      render plain: "No Apple, go away, you are drunk"
    end 

    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)
    @title = "Informatiebalie voor #{@current_user.full_name}"
  end

  def awards
    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)
    @exercises = Exercise.where(:user_id => current_user.id, :claimed_award => true)
    @title = "Awards voor #{@current_user.full_name}"
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
    # current_user.streak_lock = false

    #render plain: current_user.to_json
    #redirect_to "app/oefeningen"
    current_user.save
  end

  def my_profile
    @token = params[:token]
    logger.debug "got token: #{params}"
    user = find_user_by_token(@token)
    @title = "Profiel van #{@current_user.full_name}"
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

  def check_device
    #unless browser.device.mobile?
    #  redirect_to "/"
    #end
  end

end
