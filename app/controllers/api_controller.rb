class ApiController < ApplicationController
  # skip_before_action :verify_authenticity_token # only in rails 6
  # before_action :check_language
  before_action :authenticate_token, :except => [ :sso ]

  #protected

  def sso
    # logs a user in, with a valid external_id, nonce and time

    @user_id = params[:id].to_s
    @given_time = params[:time].to_s
    @given_hash = params[:hash].to_s

    # check original hash
    data = @given_time + "_" + @user_id + "_" + NONCE
    @hash = Digest::SHA256.hexdigest data

    # debug only
    if params[:debug]
      @time = Time.now.to_i.to_s
      data2 = @time + "_" + @user_id + "_" + NONCE
      @hash2 = Digest::SHA256.hexdigest data2
      @debug_url = "?id=#{@user_id}&time=#{@time}&hash=#{@hash2}&debug=true"
    end


    @given_hash == @hash ? hash_matched = true : hash_matched = false
    #@given_time.to_i > (DateTime.now - 30.seconds).to_i ? time_limit_met = true : time_limit_met = false
    @given_time.to_i > (DateTime.now.utc - 30.seconds).to_i ? time_limit_met = true : time_limit_met = false
    hash_matched && time_limit_met ? access_granted = true : access_granted = false

    logger.debug "SSO for user #{@user_id}"
    logger.debug "hash matches? #{hash_matched}"
    logger.debug "time limit was met? #{time_limit_met}"
    logger.debug "access was granted? #{access_granted}"

    if access_granted
      @user = User.where(:external_id => @user_id).first
      logger.debug "Signing in user: #{@user_id} => #{@user}"
      sign_in(@user)

      # if a mail was send and a client was found, go there
      if params[:email]
        @client = User.where(:email => params[:email], :logopedist_id => @user.id.to_s ).first
        logger.debug "has email and client #{params[:email]}, #{@client}"
        unless @client.nil?
          redirect_to "/admin/users/#{@client.id.to_s}/edit/"
          return 
        end 
      end

      redirect_to "/"
      return 

    else
      if @debug_url
        render plain: "sso completed!\n\naccess: #{access_granted}\ndebug: #{@debug_url}",  status: 403
      else
        render plain: "access denied",  status: 403
      end
    end
  end

  def add_client_for_user
    # creates a client to a user, with a specific email and a valid api key
    @client = User.new()
    @client.email = params[:client][:email]
    @client.name = params[:client][:name]
    @client.roles = [:client]
    @client.password = "t3mp0r4r|"
    @client.logopedist = @user

    if @client.save
      @user.clients << @client
      @user.save
      @client.send_reset_password_instructions
      render json: { status: "success", message: "done! add client for #{@user.name}", client: @client},  status: 201
    else
      render json: { status: "errors", message: "Error adding client for #{@user.name}", errors: @client.errors.messages},  status: 200
    end
  end

  def get_client_credentials
    # gets credentials for client for an account with api key
    @client = User.where(:email => params[:client_email]).first
    if @client.blank?
      render json: {status:"not_found_error", message: "Client with was not found in account of #{@user.name}"},  status: 400
    else
      @client.send_reset_password_instructions
      render json: {status:"success", message: "Done! password instructions where send to #{@client.email}"},  status: 200
    end
  end

  def render_unauthorized
    # not neccesary? it seems authenticate_or_request_with_http_token gives 401 regardless
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { message: 'Bad credentials' }, status: 401
  end

  def authenticate_token
    logger.debug "AUTHENTICATE LOGOPEDIST"

    # authenticate instance
    if params[:authentication_token]
      logger.debug "Authenticate with external token #{token}"
    else
      authenticate_or_request_with_http_token do |token, options|
        logger.info("Authenticate Authorization Token token #{token}")
        @user = User.where(:api_token => token).first
        if @user.blank?
          render_unauthorized
          return
        else
          return true
        end
      end
    end
  end

end
