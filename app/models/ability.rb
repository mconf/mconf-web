class Ability
  include CanCan::Ability

  def initialize(user)
    if user.superuser?
      can :manage, :all
    end
  end
end
