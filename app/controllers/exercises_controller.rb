class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]
  layout 'admin'

  # GET /exercises
  # GET /exercises.json
  def index
    # TODO: move to modal
    @limit = params[:limit].blank? ? 50 : params[:limit].to_i
    @page = params[:page].blank? ? 0 : (params[:page].to_i - 1) 

    if current_user.has_role?(:admin)
      @total = Exercise.all().count
      @exercises = Exercise.all().limit(@limit).skip(@page*@limit)      
    else
      @clients = User.where(:logopedist => current_user, :roles.in => [:client]).map{|u| u.id.to_s }
      @total = Exercise.where(:user_id.in => @clients ).count
      @exercises = Exercise.where(:user_id.in => @clients ).limit(@limit).skip(page*@limit)
    end
  end

  # GET /exercises/1
  # GET /exercises/1.json
  def show
  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
  end

  # GET /exercises/1/edit
  def edit
  end

  # POST /exercises
  # POST /exercises.json
  def create
    @exercise = Exercise.new(exercise_params)

    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.json { render :show, status: :created, location: @exercise }
      else
        format.html { render :new }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exercises/1
  # PATCH/PUT /exercises/1.json
  def update
    respond_to do |format|
      if @exercise.update(exercise_params)
        format.html { redirect_to @exercise, notice: 'Exercise was successfully updated.' }
        format.json { render :show, status: :ok, location: @exercise }
      else
        format.html { render :edit }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exercises/1
  # DELETE /exercises/1.json
  def destroy
    @exercise.destroy
    respond_to do |format|
      format.html { redirect_to exercises_url, notice: 'Exercise was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /admin/remove_exercise/1
  def remove_exercise
    if params[:id].nil?
      render plain: "Error no exercide id found"
    end

    @exercise = Exercise.find(params[:id])
    if @exercise.nil?
      render plain: "Error no exercise found for id #{params[:id]}"
    end

    user_id = @exercise.user.id.to_s

    if @exercise.destroy
      flash.alert = "Exercise was destroyed."
      flash.notice = "Exercise was destroyed."
    else
      flash.alert = "alles is kapot."
      flash.notice = "alles is kapot."
    end

    redirect_to "/admin/users/#{user_id}/edit"
    #render plain: "We've gathered here to remove exercise #{params[:id]}"
  end

  # ----------------------------------------------------------------------------
  # Fot tha app
  def update_exercise
    user = User.where(:authorisation_token => params[:token]).first()
    exercise = Exercise.find( params[:id] )

    if user.blank?
      logger.debug "# # # # # # # #"
      logger.debug "# USER COULD NOT BE VERIFIED"
      logger.debug "# # # # # # # #"
      render html:" # # # # # # # #  User could not be verified"
    end

    if exercise.user_id == user.id
      if exercise.update_progress
        render html: "Oefening afgerond!"
      else
        render html: "Oefning kon niet worden opgeslagen!"
      end
    else
      render plain: "Gebruiker en oefening komen niet overeen"
    end
  end

  # ----------------------------------------------------------------------------
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      @exercise = Exercise.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def exercise_params
      params.require(:exercise).permit(:name, :afgerond, :video, :description, :preset, :claimed_award, :completed, :target, :achieved, :frequency, :completed_for_the_day)
    end
end
