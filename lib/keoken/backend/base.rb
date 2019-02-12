module Keoken
  module Backend
    class Base
      attr_accessor :inputs, :bitprim_transaction, :total_inputs_amount, :tokens

      def initialize
        @inputs = []
        @tokens = []
        @bitprim_transaction = Keoken::Bitprim::Transaction.new
      end

      protected

      def build_inputs(addresses)
        utxos = addresses.map { |address| bitprim_transaction.utxos(address) }.flatten
        @total_inputs_amount = 0
        utxos.each do |utxo|
          txid = utxo['txid']
          transaction = bitprim_transaction.tx(txid)
          add_script_token(transaction['vout'])
          output = output_for_input(transaction['vout'], addresses)
          @inputs.push(
            tx_id: txid,
            position: output['n'],
            input_script: output['scriptPubKey']['hex'],
            input_amount: output['amount']
          )
          @total_inputs_amount += output['amount']
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

      def add_script_token(outputs)
        outputs.each do |vout|
          if vout['scriptPubKey']['asm'].split.first == 'OP_RETURN'
            @tokens.push(Token.new(script: vout['scriptPubKey']['hex']))
          end
        end
      end

      def output_for_input(outputs, addresses)
        outputs_in_address = outputs.reject do |vout|
          (vout['scriptPubKey']['addresses'].to_a & addresses).empty?
        end
        raise Keoken::Error::OutputNotFound if outputs_in_address.empty?
        result = outputs_in_address.first
        result['amount'] = result['value'].sub!(/\./, '').sub!(/^0+/, '').to_i
        result
      end
    end
  end
end
