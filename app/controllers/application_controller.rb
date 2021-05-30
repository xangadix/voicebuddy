class ApplicationController < ActionController::Base
  impersonates :user
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  before_action :allow_iframe
  before_action :allow_all_cors
  before_action :cors_set_access_control_headers
  before_action :check_locale
  # before_action :sign_in_user

  def index

    logger.debug "HEllo from application #{current_user.inspect}"


    logger.debug user_signed_in?
    logger.debug current_user
    logger.debug user_session
    logger.debug "---"

    # kick it!
    unless current_user.nil?
      logger.debug "has roles #{current_user.roles}"
      if current_user.has_role? :superadmin
        redirect_to "/admin/superadmin"
      elsif current_user.has_role? :admin
        redirect_to "/admin/index"
      elsif current_user.has_role? :logopedist
        # redirect_to "/admin/consultant"
        redirect_to "/admin/index"
      elsif current_user.has_role? :client
        redirect_to "/app/"
      elsif current_user.has_role? :demo
        redirect_to "/site/demo"
      else
        render plain: "#{current_user.inspect} ... you have No RoL3, please contact support."
      end

    else

      # slechts op bezoek
      redirect_to "/site/index"
    end

  end

  def inloggen
    redirect_to "/users/sign_in"
  end

  def inschrijven
    redirect_to "/users/sign_up"
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def sign_in_user
    if current_user.nil?
      user = User.where(:email => "client@voicebuddy.com").first
      sign_in(user)
    end
  end

  def cors_preflight_check
    #if request.method == 'OPTIONS'
    #end
    #cors_set_access_control_headers
    render json: {"hetis"=>"ok"}

  end

  protected

  def cors_set_access_control_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, X-User-Token, X-User-Email'
    response.headers['Access-Control-Max-Age'] = '1728000'
  end

  def allow_all_cors
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, PUT, PATCH, POST, OPTIONS'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Access-Control-Allow-Headers'] = '*'
  end

  def check_locale
    logger.debug "checking locale ... #{cookies[:locale]} #{params[:locale]}"

    unless cookies[:locale].nil?
      I18n.locale = cookies[:locale]
    end

    unless params[:locale].nil?
      I18n.locale = params[:locale]
      cookies[:locale] = params[:locale]
    end
  end


end
