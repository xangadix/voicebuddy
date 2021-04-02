# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :create, :read, :edit, :update, :destroy, :to => :creud
    #if user.role == "doctor"
    #  can :manage, :all
    #  can :start_consult, Appointment
    #  can :wachtrij, Appointment
    #end

    #if user.role == "assistant"
    #  can :manage, :all
    #end
    if user.has_role? :super_admin
      # magic powers
    end

    # Roles
    if user.has_role? :admin
      can :manage, :all
    end

    if user.has_role? :logopedist
      # can manage user where role is client and organisation is user.organisation
    end

    if user.has_role? :client
      # can see appointments
      # can see app
    end

    # DivisionAdmin
    #if user.has_role? :division_admin
      # Manage divisions clients, users and appointments
    #  can :manage, Appointment, user: { id: user.divisions.map(&:user_ids).flatten } # Must be a better way for this
    #  cannot :start_consult, Appointment  # Controller thing. How to define? Probably need to move methods to Model
    #  cannot :wachtrij, Appointment       # Controller thing. How to define? Probably need to move methods to Model
    #  can :manage, Client, instance_id: user.instance_id
    #  can :create, Client


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
