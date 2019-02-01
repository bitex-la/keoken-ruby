module Keoken
  class OutputNotFound < StandardError
    def initialize(msg = 'Missing output')
      super
    end
  end
end

