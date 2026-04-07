# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Disallows the use of `before` hooks in specs.
      #
      # @example
      #   # bad
      #   before { do_something }
      #   before(:each) { do_something }
      #
      #   # good
      #   # Inline setup directly in the example.
      class NoBeforeHook < Base
        MSG = "Do not use `before` hooks."

        # @!method before_hook?(node)
        def_node_matcher(:before_hook?, <<~PATTERN)
          (block (send nil? :before ...) ...)
        PATTERN

        def on_block(node)
          return unless before_hook?(node)

          add_offense(node)
        end

        alias on_numblock on_block
      end
    end
  end
end
