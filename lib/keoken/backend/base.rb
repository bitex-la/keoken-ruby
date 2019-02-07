module Keoken
  module Backend
    class Base
      attr_accessor :inputs, :bitprim_transaction, :total_inputs_amount

      def initialize
        @inputs = []
        @bitprim_transaction = Keoken::Bitprim::Transaction.new
      end

      protected

      def build_inputs(address)
        utxos = bitprim_transaction.utxos(address)
        @total_inputs_amount = 0
        utxos.each do |utxo|
          txid = utxo['txid']
          transaction = bitprim_transaction.tx(txid)
          outputs = transaction['vout'].select do |vout|
            addresses = vout['scriptPubKey']['addresses']
            addresses.any? { |vout_address| vout_address == address } if addresses
          end
          raise Keoken::Error::OutputNotFound if outputs.empty?
          output = outputs.first
          amount = output['value'].sub!(/\./, '').sub!(/^0+/, '').to_i
          @inputs.push(
            tx_id: txid,
            position: output['n'],
            input_script: output['scriptPubKey']['hex'],
            input_amount: amount
          )
          @total_inputs_amount += amount
        end
      end

      def build_fee(type)
        [@total_inputs_amount,
         ((10 * @inputs.length + 35 * output_length(type)) * @bitprim_transaction.estimate_fee.to_f)
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
