class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_user_role
  layout "admin"

  def index
  end

  def dashboard
    render plain: "Dashboard #{current_user.inspect}"
  end

  def logopedisten
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
