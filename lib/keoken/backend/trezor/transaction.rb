module Keoken
  module Backend
    module Trezor
      class Transaction < Keoken::Backend::Base
        attr_accessor :to_json

        # Create the transaction to broadcast in order to create tokens.
        #
        # @param address [String] Address that will contain the token.
        # @param path [Array] Address derivation path.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::Trezor::Transaction] A serialized object ready for Trezor signing.
        #
        def build_for_creation(address, path, script)
          build_inputs(address)
          total, fee = build_fee(:create)
          output_amount = total - fee.to_i
          create(@inputs, path, address, output_amount, script)
        end

        # Create the transaction to broadcast in order to send amount between tokens.
        #
        # @param address [String] Address that will contain the token.
        # @param address_dest [String] Address to receive the tokens.
        # @param path [Array] Address derivation path.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::Trezor::Transaction] A serialized object ready for Trezor signing.
        #
        def build_for_send_amount(address, address_dest, path, script)
          build_inputs(address)
          total, fee = build_fee(:send)
          output_amount = total - (fee.to_i * 2)
          output_amount_to_addr2 = fee.to_i
          send(@inputs, path, output_amount, address, output_amount_to_addr2, address_dest, script)
        end

        private

        def create(inputs, path, address, output_amount, script)
          {
            inputs:
              inputs.map do |input|
                {
                  address_n: path,
                  prev_index: input[:position],
                  prev_hash: input[:tx_id],
                  amount: input[:input_amount].to_s
                }
              end,
            outputs: [
              {
                address: Cashaddress.from_legacy(address),
                amount: output_amount.to_s,
                script_type: 'PAYTOADDRESS'
              },
              {
                op_return_data: script,
                amount: '0',
                script_type: 'PAYTOOPRETURN'
              }
            ]
          }
        end

        def send(inputs, path, output_amount, address, output_amount_to_addr2, addr2, script)
          {
            inputs:
              inputs.map do |input|
                {
                  address_n: path,
                  prev_index: input[:position],
                  prev_hash: input[:tx_id],
                  amount: input[:input_amount].to_s
                }
              end,
            outputs: [
              {
                address: Cashaddress.from_legacy(address),
                amount: output_amount.to_s,
                script_type: 'PAYTOADDRESS'
              },
              {
                address: Cashaddress.from_legacy(addr2),
                amount: output_amount_to_addr2.to_s,
                script_type: 'PAYTOADDRESS'
              },
              {
                op_return_data: script,
                amount: '0',
                script_type: 'PAYTOOPRETURN'
              }
            ]
          }
        end
      end
    end
  end
end