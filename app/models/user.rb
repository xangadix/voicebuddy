class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # includes roles
  include UserRolable
  field :roles, :type => Array, default: []
  belongs_to :resource, polymorphic: true, optional: true

  # can have exercises
  has_many :exercises

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time


  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  # ----------------------------------------------------------------------------
  # I'll write my own role system with booze and hookers

  field :name, type: String, default: ""

  # there must be a way to do it better
  # but for now lets save user ids
  field :clients, type: Array, default: []

  # as a client, a user has many excercises
  has_many :exercises

  # just for the heck of it
  field :first_name, type: String, default: ""
  field :suffix, type: String, default: ""
  field :last_name, type: String, default: ""
  field :gender, type: String, default: ""
  field :date_of_birth, type: String, default: ""
  field :notes, type: String, default: ""

  def full_name
    unless name.blank?
      self.name
    else
      "#{self.first_name} #{self.suffix} #{self.last_name}"
    end
  end
  # optionsl callback, after_add, before_remove, after_remove

  #def before_add_method(role)
    # do something before it gets added
  #end
end