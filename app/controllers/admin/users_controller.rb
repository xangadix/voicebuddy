class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  layout 'admin'
  include ApplicationHelper

  # https://github.com/bogdan/datagrid ?
  # https://github.com/bogdan/datagrid/wiki/Frontend

  # GET /users
  # GET /users.json
  def index

    if current_user.nil?
      redirect_to "/"
      return
    end

    unless current_user.has_role?(:admin )
      redirect_to "/admin/clients"
      return
    end
    # @page = ( params[:page]).to_i || 0
    # @resource = User.all
    # @total = @resource.count
    # @users = @resource.skip( @page * PER_PAGE ).limit( PER_PAGE)

    @page = ( params[:page]).to_i || 0
    if params[:search]
      @search = params[:search]
      @resource = User.or([{:name => /#{params[:search]}/i},{:email => /#{params[:search]}/i}] ).sort(:created_at => -1)
    else
      @search = ""
      @resource = User.all.sort(:created_at => -1)
    end
    @total = @resource.count
    @users = @resource.skip( @page * PER_PAGE ).limit( PER_PAGE )

  end


  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    # back
    @back = request.env["HTTP_REFERER"].split('https://app.voicebuddy.nl')[1]
    logger.debug "checking referrer"
    logger.debug @back

    # save ownership
    if current_user.has_role?(:logopedist)
      @user.logopedist = current_user
      @user.roles = [:client]
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to '/admin/users', notice: 'Alle wijzigingen zijn opgeslagen.' }
        format.json { render :show, status: :created, location: @user }
      else
        #format.html {
        #  logger.debug " --- "
        #  logger.debug "ERRORS: #{@user.errors.inspect}"
        #  logger.debug " --- "
        #  format.html { redirect_to '/admin/clients', notice: @user.errors.messages }
        #  redirect_to '/admin/clients'
        #}
        format.html {
          if current_user.has_role?(:logopedist)
            render 'admin/clients/new'
          else
            render :new
          end
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    #logger.debug " -------------------------- UPDATE : #{@user} #{user_params}"
    logger.debug " -------------------------- UPDATE : #{user_params[:bulk_selected_new_exercies]}"
    
    add_exercises = JSON.parse( user_params[:bulk_selected_new_exercies] )
    user_params.delete(:bulk_selected_new_exercies)
    
    logger.debug "parsed values:" + add_exercises.inspect 

    add_exercises.each do |ex|
      #add_new_exercise
      logger.debug "add: #{ex}"
      add_new_exercise( @user.id.to_s, ex["exercise_id"], ex["frequency"], ex["target"],  )
    end
    

    respond_to do |format|
      if @user.update(user_params)
        # format.html { redirect_to '/admin/users', notice: 'Alle wijzigingen zijn opgeslagen.' }
        format.html { render :edit, notice: 'Alle wijzigingen zijn opgeslagen.'  }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    back = request.env["HTTP_REFERER"].split('https://app.voicebuddy.nl')[1]
    if back.nil?
      back = request.env["HTTP_REFERER"].split('https://dev.voicebuddy.nl')[1]
    end

    respond_to do |format|
      format.html { redirect_to back, notice: "gebruiker #{@user.full_name} is verwijderd." }
      format.json { head :no_content }
    end
  end

  # IMPERSONATION --------------------------------------------------------------
  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  # internal use
  def add_new_exercise( _user_id, _ex_id, _target = nil, _frequency = nil)

    @user = User.find(_user_id)

    @user.exercises.each do |ex|
      logger.debug "trrr... #{ex.preset}, #{_ex_id}"
      if ex.preset.to_i == _ex_id.to_i # $$ ex.preset.claim_reward
        # skip
        logger.debug "oefening #{_ex_id} was al toegewezen aan de client"
        return
      end
    end

    preset = lookup_exercies( _ex_id )
    @exercise = Exercise.new()
    @exercise.user = @user
    @exercise.preset = _ex_id
    @exercise.name = preset["oefening"]

    if _target
      @exercise.target = _target.to_i
    else 
      @exercise.target = preset["target"]
    end

    if _frequency
      @exercise.frequency = _frequency.to_i
    else
      @exercise.frequency = preset["frequentie"]
    end

    @exercise.material = preset["materiaal"]
    @exercise.save()

    @user.exercises << @exercise
    @user.save

  end

  def add_exercise

    # {
    #  :id => 0,
    #  :name => "oefening 1",
    #  :video => "720p_5000kbps_h264_1.mp4",
    #  :beschrijving => "Lorem Ipsum solet dormit"
    #},

    # needs user to check doubloures
    @user = User.find(params[:id])

    # geen dubbele exercises
    # if user has exercis preset --> refuse
    @user.exercises.each do |ex|
      if ex.preset == params[:ex_id] # $$ ex.preset.claim_reward
        flash[:alert] = "User already has this preset."
        redirect_to "/admin/users/#{params[:id]}"
        return
      end
    end

    add_new_exercise( params[:id], params[:ex_id], params[:target], params[:freqency] )
    redirect_to "/admin/users/#{params[:id]}/edit#just_added"
  end

  def remove_exercise
    @exercise = Exercise.find(params[:ex_id])
    @exercise.destroy!
    redirect_to "/admin/users/#{params[:id]}/edit"
  end

  # not used
  def preview_video
    render :layout => false     
    @test = "123_rood_wit_blauw"
  end
  #

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      #params.fetch(:user, {:name, :email})
      params.require(:user).permit(:name, :email, :password, :language, :external_id, :logopedist, :bulk_selected_new_exercies, :roles => [])
    end
end
