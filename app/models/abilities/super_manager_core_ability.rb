module Abilities
  class SuperManagerCoreAbility
    include CanCan::Ability

    def initialize(user)

      can :assign, Role do |r|
        r.name != "admin"
      end

      # can manage SavedQuery
      can :manage, SavedQuery
    end
  end
end