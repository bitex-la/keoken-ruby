module Keoken
  class Parser
    attr_accessor :data, :transaction_type, :name, :amount
    def initialize(script)
      binary = script.htb
      @data  = binary.bytes
    end

    def prefix
      result = @data.slice!(0)
      raise Keoken::DataNotParsed, 'OP_RETURN missing' unless result == Bitcoin::Script::OP_RETURN.to_i
      result = @data.slice!(0)
      raise Keoken::DataNotParsed, 'Prefix size missing' unless result == Keoken::PREFIX_SIZE.to_i
      result = @data.slice!(0..Keoken::PREFIX.htb.bytes.length - 1)
      raise Keoken::DataNotParsed, 'Prefix not provided' unless result == Keoken::PREFIX.htb.bytes
      bytesize = @data.slice!(0)
      raise Keoken::DataNotParsed, 'Bytesize not provided' unless bytesize == @data.length
    end

    def set_transaction_type
      result = @data.slice!(0..3).join
      @transaction_type = if result == Keoken::TYPE_CREATE_ASSET
        :create
      elsif result == Keoken::TYPE_SEND_TOKEN
        :send
      else
        raise Keoken::DataNotParsed, 'Transaction type not valid'
      end
      @transaction_type
    end

    def name_or_id
      name = []
      end_of_name = false
      loop do
        tmp = @data.slice!(0)
        end_of_name ||= tmp > 0
        next if tmp.zero? && !end_of_name
        break if tmp.zero? && end_of_name
        name.push tmp
      end
      if @transaction_type == :create
        name.map { |n| n.to_s(16).htb }.join
      elsif @transaction_type == :send
        name.map { |n| n.to_s(16) }.join
      end
    end

    def amount
      @data.map { |byte| byte.zero? ? "#{byte}0" : byte.to_s }.join.to_i
    end
  end
end
