class Admin::ClientsController < Admin::UsersController
  # after safe redirect to clients ?
  # https://github.com/bogdan/datagrid ?

  def index
    # current_user.clients.each lookup
    #     flash[:notice] = "I has a notice."
    @users = User.where(:roles.in => [:client])
  end

  def datatables
  end

end
