module Keoken
  class IdNotFound < StandardError
    def initialize(msg='Missing id')
      super
    end
  end
end
