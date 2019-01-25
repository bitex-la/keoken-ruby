class Bitcoin::Script
  def self.to_custom_script(data=nil)
    [data].pack("H*")
  end
end
