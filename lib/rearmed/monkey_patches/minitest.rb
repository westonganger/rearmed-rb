if defined?(Minitest::Assertions)

  enabled = Rearmed.enabled_patches[:minitest] == true

  Minitest::Assertions.module_eval do

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :minitest, :assert_changed)
      def assert_changed(expression, &block)
        #unless expression.respond_to?(:call)
        #  expression = lambda{ eval(expression, block.binding) }
        #  expression = lambda{ block.binding.eval("#{expression}") }
        #end
        old = expression.call
        block.call
        refute_equal old, expression.call
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :minitest, :assert_not_changed)
      def assert_not_changed(expression, &block)
        unless expression.respond_to?(:call)
          expression = lambda{ eval(expression, block.binding) }
        end
        old = expression.call
        block.call
        assert_equal old, expression.call
      end
    end

  end

end
