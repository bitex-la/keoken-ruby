module Keoken
  class Token
    attr_reader :data_script, :hex

    def initialize(id, amount)
      @data_script =
       [Keoken::VERSION,
        Keoken::TYPE_SEND_TOKEN,
        Keoken::PREFIX_BYTE_ASSET_ID[0..(Keoken::ASSET_ID_SIZE - id.to_s.length - 1)] + id.to_s,
        Keoken::PREFIX_BYTE_AMOUNT[0..(Keoken::AMOUNT_SIZE - amount.to_s.length - 1)] + amount.to_s].flatten.join

      data_length = @data_script.htb.bytesize.to_s(16)

      @hex = [Bitcoin::Script::OP_RETURN.to_s(16), Keoken::PREFIX_SIZE, Keoken::PREFIX, data_length].join + data_script
    end
  end
end