module Keoken
  class Token
    attr_accessor :data_script, :name, :id, :amount, :transaction_type

    # Creates a new token object.
    #
    # @param options [Hash] options parameters to create the token.
    # @option options [String] :name The name of token to create.
    # @option options [Number] :id The id of token to obtain an amount to send to another address.
    #
    def initialize(options = {})
      @name   = options[:name]
      @id     = options[:id]
    end

    # Generate the script to create a token.
    #
    # @param amount [Number] The token amount limit.
    #
    # @return [Keoken::Token] An object with the data needed to crate the token.
    #
    def create(amount)
      raise Keoken::NameNotFound unless @name
      @data_script =
        [
          Keoken::VERSION_NODE,
          Keoken::TYPE_CREATE_ASSET,
          name_to_hex(@name),
          Keoken::PREFIX_BYTE_AMOUNT[0..prefix_length(amount)] + amount.to_s
        ].flatten.join
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
      asset_length = Keoken::ASSET_ID_SIZE - @id.to_s.length - 1
      @data_script =
        [
          Keoken::VERSION_NODE,
          Keoken::TYPE_SEND_TOKEN,
          Keoken::PREFIX_BYTE_ASSET_ID[0..asset_length] + @id.to_s,
          Keoken::PREFIX_BYTE_AMOUNT[0..prefix_length(amount)] + amount.to_s
        ].flatten.join
      self
    end

    # Hexadecimal value of script.
    #
    # @return [String] Hexadecimal value of script token.
    def hex
      [
        Bitcoin::Script::OP_RETURN.to_s(16),
        Keoken::PREFIX_SIZE,
        Keoken::PREFIX,
        data_length
      ].join + @data_script
    end

    # JSON serialization of object
    #
    # return [String] JSON serialization of token object.
    def to_json
      {
        id: @id,
        name: @name,
        amount: @amount,
        transaction_type: @transaction_type
      }.to_json
    end

    # Deserialization of object
    #
    # return [Hash] Deserialization of token object.
    def to_hash
      {
        id: @id,
        name: @name,
        amount: @amount,
        transaction_type: @transaction_type
      }
    end

    def parse_script(script)
      binary = script.htb
      bytes  = binary.bytes
      result = bytes.slice!(0)
      raise Keoken::DataNotParsed, 'OP_RETURN missing' unless result == Bitcoin::Script::OP_RETURN.to_i
      result = bytes.slice!(0)
      raise Keoken::DataNotParsed, 'Prefix size missing' unless result == Keoken::PREFIX_SIZE.to_i
      result = bytes.slice!(0..Keoken::PREFIX.htb.bytes.length - 1)
      raise Keoken::DataNotParsed, 'Prefix not provided' unless result == Keoken::PREFIX.htb.bytes
      bytesize = bytes.slice!(0)
      raise Keoken::DataNotParsed, 'Bytesize not provided' unless bytesize == bytes.length
      result = bytes.slice!(0..3)
      @transaction_type =
        if result.join == Keoken::TYPE_CREATE_ASSET
          :create
        elsif result.join == Keoken::TYPE_SEND_TOKEN
          :send
        else
          raise Keoken::DataNotParsed, 'Transaction type not valid'
        end
      name = []
      end_of_name = false
      loop do
        tmp = bytes.slice!(0)
        end_of_name ||= tmp > 0
        next if tmp.zero? && !end_of_name
        break if tmp.zero? && end_of_name
        name.push tmp
      end

      @amount = bytes.map { |byte| byte.zero? ? "#{byte}0" : byte.to_s }.join.to_i
      @name = name.map { |n| n.to_s(16).htb }.join
    end

    private

    def data_length
      @data_script.htb.bytesize.to_s(16)
    end

    def prefix_length(amount)
      Keoken::AMOUNT_SIZE - amount.to_s.length - 1
    end

    def name_to_hex(name)
      asset_bytes = name.bytes.map { |n| n.to_s(16) }
      asset_bytes + ['00']
    end
  end
end
