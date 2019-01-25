module Keoken
  class NameNotFound < StandardError
    def initialize(msg='Missing name')
      super
    end
  end
end

