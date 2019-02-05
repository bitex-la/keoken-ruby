module Keoken
  class Parser
    attr_accessor :data, :transaction_type, :name, :amount
    def initialize(script)
      binary = script.htb
      @data  = binary.bytes
    end

    protected

    # rubocop:disable Metrics/AbcSize
    def prefix
      raise Keoken::Error::DataNotParsed, 'OP_RETURN missing' unless @data.slice!(0) == Bitcoin::Script::OP_RETURN.to_i
      raise Keoken::Error::DataNotParsed, 'Prefix size missing' unless @data.slice!(0) == Keoken::PREFIX_SIZE.to_i
      result = @data.slice!(0..Keoken::PREFIX.htb.bytes.length - 1)
      raise Keoken::Error::DataNotParsed, 'Prefix not provided' unless result == Keoken::PREFIX.htb.bytes
      raise Keoken::Error::DataNotParsed, 'Bytesize not provided' unless @data.slice!(0) == @data.length
    end
    # rubocop:enable Metrics/AbcSize

    def set_transaction_type
      result = @data.slice!(0..3).join
      @transaction_type =
        if result == Keoken::TYPE_CREATE_ASSET
          :create
        elsif result == Keoken::TYPE_SEND_TOKEN
          :send
        else
          raise Keoken::Error::DataNotParsed, 'Transaction type not valid'
        end
      @transaction_type
    end

    def name_or_id
      name = []
      end_of_name = false
      loop do
        (tmp = @data.slice!(0)) || break
        end_of_name ||= tmp > 0
        next if tmp.zero? && !end_of_name
        break if tmp.zero? && end_of_name
        name.push tmp
      end
      name_or_id_to_hex(name)
    end

    def set_amount
      @data.map { |datum| datum.to_s(16) }.join.to_i(16)
    end

    private

    def name_or_id_to_hex(name)
      if @transaction_type == :create
        name.map { |n| n.to_s(16).htb }.join
      elsif @transaction_type == :send
        name.map { |n| n.to_s(16) }.join
      end
    end
  end
end
