module Keoken
  module Error
    class NoToken < StandardError
      def initialize(msg = 'Transaction needs at least one token')
        super
      end
    end
  end
end
