module Keoken
  module Error
    class NameNotFound < StandardError
      def initialize(msg = 'Missing name')
        super
      end
    end
  end
end

