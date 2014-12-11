module Abilities

  class BaseAbility
    include CanCan::Ability

    def initialize(user=nil)
      # remove the default aliases to remove the one that says:
      #   `alias_action :edit, to: :update`
      # we have some models where the user should have access to :update but not
      # to :edit, and this alias was binding them together.
      clear_aliased_actions
      alias_action :index, :show, to: :read
      alias_action :new, to: :create

      register_abilities(user)
    end
  end

end
