module Rearmed
  module Exceptions

    class BlockFoundError < StandardError
      def initialize
        super("Rearmed doesn't yet support a block on this method.")
      end
    end

    class NoArgOrBlockGivenError < StandardError
      def initialize
        super("Must pass an argument or a block.")
      end
    end

    class BothArgAndBlockError < StandardError
      def initialize
        super("Arguments and blocks must be used seperately.")
      end
    end

    class PatchesAlreadyAppliedError < StandardError
      def initialize
        super("Cannot change or apply patches again after `Rearmed#apply_patches!` has been called.")
      end
    end

  end
end
