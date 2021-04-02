class Admin::ClientsController < Admin::UsersController
  # after safe redirect to clients ?

  def index
    # current_user.clients.each lookup
    @users = User.where(:roles.in => [:client])
  end

  def datatables
  end

end
