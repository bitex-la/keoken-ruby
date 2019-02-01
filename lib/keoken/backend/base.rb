module Keoken
  module Backend
    class Base
      attr_accessor :inputs, :bitprim_transaction

      def initialize
        @inputs = []
        @bitprim_transaction = Keoken::Bitprim::Transaction.new
      end

      protected

      def build_inputs(address)
        utxos = bitprim_transaction.utxos(address)
        utxos.each do |utxo|
          txid = utxo['txid']
          transaction = bitprim_transaction.tx(txid)
          outputs = transaction['vout'].select do |vout|
            addresses = vout['scriptPubKey']['addresses']
            if addresses
              addresses.any? { |vout_address| vout_address == address }
            end
          end
          raise Keoken::OutputNotFound if outputs.empty?
          output = outputs.first
          @inputs.push(
            tx_id: txid,
            position: output['n'],
            input_script: output['scriptPubKey']['hex'],
            input_amount: output['value'].sub!(/\./, '').sub!(/^0+/, '').to_i
          )
        end
      end

      def build_fee(type)
        total = @inputs.map { |input| input[:input_amount].to_i }.inject(:+)
        estimate_fee = @bitprim_transaction.estimate_fee.to_f
        [total,
         ((10 + 149 * @inputs.length + 35 * output_length(type)) * estimate_fee)
           .to_s[0..9].sub!(/\./, '').sub!(/0+/, '')]
      end

      private

      def output_length(type)
        case type
        when :create
          2
        when :send
          3
        end
      end
    end
  end
end
