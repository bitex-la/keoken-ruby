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
          build_inputs([address])
          total, fee = build_fee(:create)
          output_amount = total - fee.to_i
          create(inputs: @inputs,
                 path: path,
                 address: address,
                 output_amount: output_amount,
                 script: script,
                 xpubs: xpubs)
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
          build_inputs([address])
          total, fee = build_fee(:send)
          output_amount = total - (fee.to_i * 2)
          output_amount_to_addr2 = fee.to_i
          send(inputs: @inputs,
               path: path,
               output_amount: output_amount,
               address: address,
               output_amount_to_addr2: output_amount_to_addr2,
               addr2: address_dest,
               script: script,
               xpubs: xpubs)
        end

        # Create the transaction to broadcast in order to empty the wallet.
        #
        # @param addresses [Array] Addresses that will contain the token and will be emptied.
        # @param address_dest [String] Address to receive the tokens.
        # @param path [Array] Address derivation path.
        # @param xpubs [Array] The xpubs corresponding to the multisig address.
        #
        # @return [Keoken::Backend::Trezor::Transaction] A serialized object ready for Trezor signing.
        #
        def build_for_empty_wallet(addresses, address_dest, path, xpubs = [])
          build_inputs(addresses)
          total, fee = build_fee(:send)
          raise Keoken::Error::NoToken if @tokens.empty?

          send(inputs: @inputs,
               path: path,
               output_amount: total - (fee.to_i * 2),
               address: nil,
               output_amount_to_addr2: fee.to_i,
               addr2: address_dest,
               script: token_script_for_inputs,
               xpubs: xpubs)
        end

        private

        def create(options = {})
          {
            inputs: build_trezor_inputs(options[:inputs], options[:path], options[:address], options[:xpubs]),
            outputs: [
              {
                address: Cashaddress.from_legacy(options[:address]),
                amount: options[:output_amount].to_s,
                script_type: 'PAYTOADDRESS'
              },
              {
                op_return_data: options[:script],
                amount: '0',
                script_type: 'PAYTOOPRETURN'
              }
            ]
          }
        end

        def send(options = {})
          first_output = if options[:address]
                           [
                             {
                               address: Cashaddress.from_legacy(options[:address]),
                               amount: options[:output_amount].to_s,
                               script_type: 'PAYTOADDRESS'
                             }
                           ]
                         else
                           []
                         end
          {
            inputs: build_trezor_inputs(options[:inputs], options[:path], options[:address], options[:xpubs]),
            outputs: first_output.concat(
              [
                {
                  address: Cashaddress.from_legacy(options[:addr2]),
                  amount: options[:output_amount_to_addr2].to_s,
                  script_type: 'PAYTOADDRESS'
                },
                {
                  op_return_data: options[:script],
                  amount: '0',
                  script_type: 'PAYTOOPRETURN'
                }
              ]
            )
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

        def token_script_for_inputs
          token = Token.new(id: @tokens.first.id)
          token.send_amount(@tokens.map(&:amount).inject(:+))
          token.hex
        end
      end
    end
  end
end
