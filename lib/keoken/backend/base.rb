module Keoken
  module Backend
    class Base
      attr_accessor :inputs, :bitprim_transaction, :total_inputs_amount, :tokens

      def initialize
        @inputs = []
        @tokens = []
        @total_inputs_amount = 0
        @bitprim_transaction = Keoken::Bitprim::Transaction.new
      end

      protected

      def build_inputs(addresses)
        addresses.each do |address|
          @total_inputs_amount =
            bitprim_transaction.utxos(address).inject(0) do |previous_amount, utxo|
              txid = utxo['txid']
              transaction = bitprim_transaction.tx(txid)
              add_script_token(transaction['vout'])
              output = output_for_input(txid, transaction['vout'], addresses)
              @inputs.push(output)
              previous_amount + output[:input_amount]
            end
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

      def output_for_input(txid, outputs, addresses)
        output = nil
        outputs.each do |vout|
          next if (vout['scriptPubKey']['addresses'].to_a & addresses).empty?
          output =
            {
              tx_id: txid,
              position: vout['n'],
              input_script: vout['scriptPubKey']['hex'],
              input_amount: vout['value'].sub!(/\./, '').sub!(/^0+/, '').to_i
            }
        end
        raise Keoken::Error::OutputNotFound unless output
        output
      end
    end
  end
end
