# frozen_string_literal: true

# Adds a `remove` action to `resources` and `resource` routes, next to the
# standard actions. It is meant to show a confirmation page before `destroy`:
#
#   resources :posts   # GET /posts/:id/remove => posts#remove
#   resource :account  # GET /account/remove   => accounts#remove
#
# It works with `only:` and `except:` like any other action. API-only
# resources do not get it.
#
# This patches private Rails internals. The routing spec in
# spec/routing/removable_resources_spec.rb will fail if a Rails upgrade
# breaks it.
module RemovableResources
  module DefaultActions
    def default_actions(api_only)
      api_only ? super : [*super, :remove]
    end
  end

  module MemberMappings
    private

    def set_member_mappings_for_resource
      super
      return if parent_resource.actions.exclude?(:remove)

      member { get(:remove) }
    end
  end
end

mapper = ActionDispatch::Routing::Mapper
default_actions = RemovableResources::DefaultActions
mapper::Resources::Resource.singleton_class.prepend(default_actions)
mapper::Resources::SingletonResource.singleton_class.prepend(default_actions)
mapper.prepend(RemovableResources::MemberMappings)
