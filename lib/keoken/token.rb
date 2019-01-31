module Keoken
  class Token
    attr_accessor :hex, :name, :id

    # Creates a new token object.
    #
    # @param options [Hash] options parameters to create the token.
    # @option options [String] :name The name of token to create.
    # @option options [Number] :id The id of token to obtain an amount to send to another address.
    #
    def initialize(options = {})
      @name = options[:name]
      @id = options[:id]
    end

    # Generate the script to create a token.
    #
    # @param amount [Number] The token amount limit.
    #
    # @return [Keoken::Token] An object with the data needed to crate the token.
    #
    def create(amount)
      raise Keoken::NameNotFound unless @name
      data_script =
        [Keoken::VERSION_NODE,
         Keoken::TYPE_CREATE_ASSET,
         name_to_hex(@name),
         Keoken::PREFIX_BYTE_AMOUNT[0..(Keoken::AMOUNT_SIZE - amount.to_s.length - 1)] + amount.to_s].flatten.join
      data_length = data_script.htb.bytesize.to_s(16)

      @hex = [Bitcoin::Script::OP_RETURN.to_s(16),
              Keoken::PREFIX_SIZE,
              Keoken::PREFIX,
              data_length].join + data_script
      self
    end

    # Generate the script to send an amount from one address to another.
    #
    # @param amount [Number] The amount to send.
    #
    # @return [Keoken::Token] An object with the data needed to send the amount.
    #
    def send_amount(amount)
      raise Keoken::IdNotFound unless @id
      data_script =
        [Keoken::VERSION_NODE,
         Keoken::TYPE_SEND_TOKEN,
         Keoken::PREFIX_BYTE_ASSET_ID[0..(Keoken::ASSET_ID_SIZE - @id.to_s.length - 1)] + @id.to_s,
         Keoken::PREFIX_BYTE_AMOUNT[0..(Keoken::AMOUNT_SIZE - amount.to_s.length - 1)] + amount.to_s].flatten.join

      data_length = data_script.htb.bytesize.to_s(16)

      @hex = [Bitcoin::Script::OP_RETURN.to_s(16),
              Keoken::PREFIX_SIZE,
              Keoken::PREFIX,
              data_length].join + data_script
      self
    end

    private

    def name_to_hex(name)
      asset_bytes = name.bytes.map{|n| n.to_s(16)}
      asset_bytes + ['00']
    end
  end
end
