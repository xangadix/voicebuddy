class Admin::ClientsController < Admin::UsersController
  # after safe redirect to clients ?
  # https://github.com/bogdan/datagrid ?

  def index
    # current_user.clients.each lookup
    #     flash[:notice] = "I has a notice."
    @resource = User.where(:logopedist => current_user, :roles.in => [:client])

    @page = ( params[:page]).to_i || 0
    if params[:search].blank?
      @resource = @resource
    else
      @search = params[:search]
      @resource =  User.where(:logopedist => current_user, :roles.in => [:client]).and( '$or' => [ {:name => /#{@search}/i} ,{:email => /#{@search}/i} ] )
    end
    @total = @resource.count
    @clients = @resource.skip( @page * PER_PAGE ).limit( PER_PAGE)

  end

  def datatables
  end

  def reset_password_email
    user = User.find(params[:id])
    user.send_reset_password_instructions
    redirect_to '/admin/clients', notice: 'wachtwoord instructies zijn verstuurd.'
  end

end
