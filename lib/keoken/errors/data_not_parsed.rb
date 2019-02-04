module Keoken
  class DataNotParsed < StandardError
    def initialize(msg = 'Data can not be parsed')
      super
    end
  end
end
