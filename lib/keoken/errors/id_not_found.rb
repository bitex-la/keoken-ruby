module Keoken
  module Error
    class IdNotFound < StandardError
      def initialize(msg = 'Missing id')
        super
      end
    end
  end
end
