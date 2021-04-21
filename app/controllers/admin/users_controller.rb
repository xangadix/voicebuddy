class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  layout 'admin'

  # https://github.com/bogdan/datagrid ?
  # https://github.com/bogdan/datagrid/wiki/Frontend

  # GET /users
  # GET /users.json
  def index
    @users = User.all
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

    respond_to do |format|
      if @user.save
        format.html { redirect_to '/admin/users', notice: 'Alle wijzigingen zijn opgeslagen.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to '/admin/users', notice: 'Alle wijzigingen zijn opgeslagen.' }
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
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Alle wijzigingen zijn opgeslagen.' }
      format.json { head :no_content }
    end
  end

  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  def add_exercise

    # {
    #  :id => 0,
    #  :name => "oefening 1",
    #  :video => "720p_5000kbps_h264_1.mp4",
    #  :beschrijving => "Lorem Ipsum solet dormit"
    #},

    @user = User.find(params[:id])
    @preset = EXERCISES[params[:ex_id].to_i-1]

    @exercise = Exercise.new()
    @exercise.user = @user
    @exercise.preset = @preset["id"]
    @exercise.name = @preset["naam"]
    @exercise.description = @preset["doel"]
    @exercise.video = @preset["videobestand"]
    @exercise.thumb = @preset["thumbnail"]

    # BUT... BUT... shouldn't we only save the preset id

    # @exercise.video = @preset["thumbnail"]
    # frequentie
    # @exercise.thumb = @preset[:thumbnail]
    # @exercise.percent_done = 0

    @exercise.save()

    @user.exercises << @exercise
    @user.save

    redirect_to "/admin/users/#{params[:id]}/edit"
  end

  def remove_exercise
    @exercise = Exercise.find(params[:ex_id])
    @exercise.destroy!
    redirect_to "/admin/users/#{params[:id]}/edit"
  end

  def update_exercise
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      #params.fetch(:user, {:name, :email})
      params.require(:user).permit(:name, :email, :password, :roles => [])
    end
end
