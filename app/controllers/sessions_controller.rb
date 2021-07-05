class SessionsController < Devise::SessionsController

  # before_action :set_locale
  respond_to :json, :js, :html
  after_action :allow_iframe, only: [:new]

  #skip_before_action :http_auth, :only => [:create]

  def create
    #Rails.logger.debug "CREATE ZWAAI VANUIT DE SESSION CONTROLLER"
    user_token = params[resource_name][:auth_token].presence
    user = user_token && User.find_by_authentication_token(user_token)
    if user
      sign_in resource_name, user
      user.update_attributes(device: detect_device_type)
      respond_with user, :location => after_sign_in_path_for(user)
    else
      self.resource = warden.authenticate!(auth_options)
      # set_flash_message(:notice, :signed_in) if is_navigational_format?
      # message = "#{ t('devise.sessions.signed_in') }<br><small> #{ t('devise.sessions.last_login') } #{ resource.last_sign_in_at.strftime('%e %b %Y %R') }</small>"
      # flash[:warning] = message.html_safe if is_navigational_format?

      sign_in(resource_name, resource)
      path = after_sign_in_path_for(resource)
      respond_with resource, :location => path
    end
  end

  #def after_sign_out_path_for(resource)
  #  redirect_to controller: :sessions, action: :new
  #  return
  #end

  def new
    #Rails.logger.debug "NIEUEW ZWAAI VANUIT DE SESSION CONTROLLER"
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?
    if request.subdomains.blank? || request.subdomains.first != "login"
      respond_with(resource, serialize_options(resource) )
    else
      respond_with(resource, serialize_options(resource), layout: "iframe" )
    end
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
