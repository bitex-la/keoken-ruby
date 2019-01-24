module Keoken
  class Asset
    attr_reader :data_script, :hex

    def initialize(name, amount)
      @data_script =
        [Keoken::VERSION,
        Keoken::TYPE_CREATE_ASSET,
        name_to_hex(name),
        Keoken::PREFIX_BYTE_AMOUNT[0..(Keoken::AMOUNT_SIZE - amount.to_s.length - 1)] + amount.to_s].flatten.join
      
      data_length = @data_script.htb.bytesize.to_s(16)

      @hex = [Bitcoin::Script::OP_RETURN.to_s(16), Keoken::PREFIX_SIZE, Keoken::PREFIX, data_length].join + @data_script
    end

    private
    def name_to_hex(name)
      asset_bytes = name.bytes.map{|n| n.to_s(16)}
      asset_bytes + ['00']
    end
  end
end