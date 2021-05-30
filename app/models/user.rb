class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # includes roles
  include UserRolable
  field :roles, :type => Array, default: []

  # a logopedist can have many clients
  # a client has one logopedists
  # both are users
  has_many :clients, :class_name => 'User', :foreign_key => :client_id
  belongs_to :logopedist, :class_name => 'User', optional: true

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
  field :client_id, type: String, default: ""

  # just for the heck of it
  field :first_name, type: String, default: ""
  field :suffix, type: String, default: ""
  field :last_name, type: String, default: ""
  field :gender, type: String, default: ""
  field :date_of_birth, type: String, default: ""

  field :notes, type: String, default: ""
  field :authorisation_token, type: String, default: ""
  field :language, type: String, default: "nl"

  field :has_seen_intro, type: Boolean, default: false

  field :last_streak_update, type: DateTime, default: DateTime.now
  field :next_streak_update, type: DateTime, default: DateTime.now + 1.day
  field :streak_target, type: Integer, default: 7
  field :claimed_streaks, type: Integer, default: 0
  field :streak, type: Integer, default: 0
  field :streak_lock, type: Boolean, default: false #locks the streak untill reset

  def full_name
    unless name.blank?
      self.name
    else
      "#{self.first_name} #{self.suffix} #{self.last_name}"
    end
  end

  def set_authorisation_token
    token = SecureRandom.urlsafe_base64(nil, false)
    self.authorisation_token = token
    self.save
    return token
  end

end
