require 'money-tree'

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
        # @param xpubs [Array] The xpubs corresponding to the multisig address.
        #
        # @return [Keoken::Backend::Trezor::Transaction] A serialized object ready for Trezor signing.
        #
        def build_for_creation(address, path, script, xpubs = [])
          build_inputs(address)
          fee = build_fee(:create)
          create(@inputs, path, address, fee.to_i, script, xpubs)
        end

        # Create the transaction to broadcast in order to send amount between tokens.
        #
        # @param address [String] Address that will contain the token.
        # @param address_dest [String] Address to receive the tokens.
        # @param path [Array] Address derivation path.
        # @param script [String] The token script.
        # @param xpubs [Array] The xpubs corresponding to the multisig address.
        #
        # @return [Keoken::Backend::Trezor::Transaction] A serialized object ready for Trezor signing.
        #
        def build_for_send_amount(address, address_dest, path, script, xpubs = [])
          build_inputs(address)
          fee = build_fee(:send)
          output_amount = fee.to_i * 2
          output_amount_to_addr2 = fee.to_i
          send(@inputs, path, output_amount, address, output_amount_to_addr2, address_dest, script, xpubs)
        end

        private

        def create(inputs, path, address, output_amount, script, xpubs)
          {
            inputs: build_trezor_inputs(inputs, path, address, xpubs),
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

        def send(inputs, path, output_amount, address, output_amount_to_addr2, addr2, script, xpubs)
          {
            inputs: build_trezor_inputs(inputs, path, address, xpubs),
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

        def build_trezor_inputs(inputs, path, address, xpubs)
          inputs.map do |input|
            hash =
              {
                address_n: path,
                prev_index: input[:position],
                prev_hash: input[:tx_id],
                amount: input[:input_amount].to_s
              }
            hash.merge(build_multisig(address, path, xpubs))
          end
        end

        def build_multisig(address, path, xpubs)
          if xpubs.empty?
            {}
          else
            {
              script_type: 'SPENDMULTISIG',
              multisig:
                {
                  signatures: ['', '', ''],
                  m: 2,
                  pubkeys: xpubs.map do |xpub|
                    node = MoneyTree::Node.from_bip32(xpub)
                    {
                      address_n: path,
                      node:
                        {
                          chain_code: node.chain_code.to_s(16),
                          depth: 0,
                          child_num: 0,
                          fingerprint: 0,
                          public_key: node.public_key.key
                        }
                    }
                  end
                }
            }
          end
        end
      end
    end
  end
end
