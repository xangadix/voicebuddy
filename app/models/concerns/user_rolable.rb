module UserRolable
  extend ActiveSupport::Concern

  ROLES = [ :superadmin, :admin, :logopedist, :client, :demo ]

  def has_role?(_role)
    roles && (roles.include?(_role.to_sym) || roles.include?(_role.to_s))
  end

  def has_roles?(_roles)
    roles && !(roles.map(&:to_sym) & _roles.map(&:to_sym)).blank?
  end

  def self.new_roles
    all.each do |u|
      if u.doctor?
        u.roles = [:consultant]
      else
        u.roles = [:division_manager]
      end
      u.save
    end
  end

  # right, just get this to work
  def roles=(roles)
    # puts "roles?"
    roles = roles.select { |role| ROLES.include? role.to_sym }.map(&:to_sym)
    super
  end

  def role_test
    # puts "could we have roles"
  end

  def roles_body_class
    return 'green' if has_role? :platform_admin
    return 'red' if has_role? :sense
    return ''
  end

  # ----------------------------------------------------------------------------

  # depricated
  def check_role?(_role)
    found = false
    self.roles.each do |r|
      puts "#{r.name}, #{_role.to_s}"
      if r.name == _role.to_s
        found = true
      end
    end

    found
  end

  # ----------------------------------------------------------------------------

end
