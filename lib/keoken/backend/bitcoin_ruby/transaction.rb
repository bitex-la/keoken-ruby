module Keoken
  module Backend
    module BitcoinRuby
      class Transaction < Keoken::Backend::Base
        attr_accessor :to_json, :raw
        include Bitcoin::Builder

        # Create the transaction to broadcast in order to create tokens.
        #
        # @param address [String] Address that will contain the token.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def build_for_creation(address, key, script)
          build(address, nil, key, script, :create)
        end

        # Create the transaction to broadcast in order to send amount between tokens.
        #
        # @param address [String] Address that will contain the token.
        # @param address_dest [String] Address to receive the tokens.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def build_for_send_amount(address, address_dest, key, script)
          build(address, address_dest, key, script, :send)
        end

        # Invoke the methods creating the transaction automatically.
        #
        # @param address [String] Address that will contain the token.
        # @param addr2 [String] Address to receive the tokens.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        # @param type [Symbol] :create for creation and :send to send tokens.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def build(address, addr2, key, script, type)
          build_inputs([address])
          total, fee = build_fee(type)
          case type
          when :create
            output_amount = total - fee.to_i
            create(@inputs, output_amount, key.addr, key, script)
          when :send
            output_amount = total - (fee.to_i * 2)
            output_amount_to_addr2 = fee.to_i
            send_amount(@inputs, output_amount, key.addr, output_amount_to_addr2, addr2, key, script)
          end
        end

        # Create the transaction to broadcast in order to create tokens.
        #
        # @param inputs [Array] Inputs to sign.
        # @param output_amount [Number] Amount to send to output, should be enough for feed.
        # @param output_address [String] Address that will contain the token.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def create(inputs, output_amount, output_address, key, script)
          tx = build_tx do |t|
            inputs.each do |input|
              t.input do |i|
                i.prev_out(input[:tx_id], input[:position], input[:input_script].htb, input[:input_amount], 0)
                i.signature_key(key)
              end
            end
            t.output do |o|
              o.value output_amount
              o.script do |s|
                s.recipient(output_address)
              end
            end
            t.output do |o|
              o.value 0
              o.to(script, :custom)
            end
          end
          @to_json = tx.to_json
          @raw = tx.to_payload.bth
          self
        end

        # Create the transaction to broadcast in order to send amount between tokens.
        #
        # @param inputs [Array] Inputs to sign.
        # @param output_amount [Number] Amount to send to output, should be enough for feed.
        # @param output_address [String] Address that will contain the token.
        # @param output_amount_to_addr2 [Number] Amount to send to the output address to receive the tokens, should be low enough for feed.
        # @param addr2 [String] Address to receive the tokens.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def send_amount(inputs, output_amount, output_address, output_amount_to_addr2, addr2, key, script)
          tx = build_tx do |t|
            inputs.each do |input|
              t.input do |i|
                i.prev_out(input[:tx_id], input[:position], input[:input_script].htb, input[:input_amount], 0)
                i.signature_key(key)
              end
            end
            t.output do |o|
              o.value output_amount_to_addr2
              o.script do |s|
                s.recipient(addr2)
              end
            end
            t.output do |o|
              o.value output_amount
              o.script do |s|
                s.recipient(output_address)
              end
            end
            t.output do |o|
              o.value 0
              o.to(script, :custom)
            end
          end
          @to_json = tx.to_json
          @raw = tx.to_payload.bth
          self
        end
      end
    end
  end
end
