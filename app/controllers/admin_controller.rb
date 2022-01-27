class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_user_role
  layout "admin"
  @@per_page = 4

  def index
  end

  def dashboard
    render plain: "Dashboard #{current_user.inspect}"
  end

  def logopedisten
    @page = ( params[:page]).to_i || 0
    if params[:search].blank?
      @resource = User.where(:roles.in => ["logopedist"])
    else
      @search = params[:search]
      @resource = User.where(:roles.in => ["logopedist"]).and( '$or' => [ {:name => /#{@search}/i} ,{:email => /#{@search}/i} ] )
    end
    @total = @resource.count
    @users = @resource.skip( @page * PER_PAGE ).limit( PER_PAGE)
  end

  def clients
  end

  def logs
  end

  def my_profile
  end

  private

    def verify_user_role
      unless current_user.has_role?(:logopedist) || current_user.has_role?(:admin) || current_user.has_role?(:superadmin)
        redirect_to "/", notice: "you don't have enough access previlages"
        #render plain: "you don't have enough access previlages"
      end

    end


end
