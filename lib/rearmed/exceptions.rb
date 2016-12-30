module Rearmed
  module Exceptions

    class BlockFoundError < StandardError
      def initialize(klass=nil)
        super("Rearmed doesn't yet support a block on this method.")
      end
    end

    class NoArgOrBlockGivenError < StandardError
      def initialize(klass=nil)
        super("Must pass an argument or a block.")
      end
    end

    class BothArgAndBlockError < StandardError
      def initialize(klass=nil)
        super("Arguments and blocks must be used seperately.")
      end
    end

  end
end
