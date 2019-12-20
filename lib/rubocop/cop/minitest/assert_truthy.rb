# frozen_string_literal: true

module RuboCop
  module Cop
    module Minitest
      # This cop enforces the test to use `assert(actual)`
      # instead of using `assert_equal(true, actual)`.
      #
      # @example
      #   # bad
      #   assert_equal(true, actual)
      #   assert_equal(true, actual, 'the message')
      #
      #   # good
      #   assert(actual)
      #   assert(actual, 'the message')
      #
      class AssertTruthy < Cop
        include ArgumentRangeHelper

        MSG = 'Prefer using `assert(%<arguments>s)` over ' \
              '`assert_equal(true, %<arguments>s)`.'

        def_node_matcher :assert_equal_with_truthy, <<~PATTERN
          (send nil? :assert_equal true $_ $...)
        PATTERN

        def on_send(node)
          assert_equal_with_truthy(node) do |actual, rest_receiver_arg|
            message = rest_receiver_arg.first

            arguments = [actual.source, message&.source].compact.join(', ')

            add_offense(node, message: format(MSG, arguments: arguments))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            assert_equal_with_truthy(node) do |actual|
              corrector.replace(node.loc.selector, 'assert')
              corrector.replace(
                first_and_second_arguments_range(node), actual.source
              )
            end
          end
        end
      end
    end
  end
end
