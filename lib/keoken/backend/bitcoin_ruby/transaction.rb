module Keoken
  module Backend
    module BitcoinRuby
      class Transaction
        attr_accessor :to_json, :raw
        extend Bitcoin::Builder

        # Create the transaction to broadcast in order to create tokens.
        #
        # @param tx_id [String] Transaction hash.
        # @param position [Number] Transaction index of output.
        # @param input_script [String] ScriptPubKey from input.
        # @param input_amount [Number] Total amount from transaction input.
        # @param output_amount [Number] Amount to send to output, should be enough for feed.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def self.create(tx_id, position, input_script, input_amount, output_amount, key, script)
          token = new
          tx = build_tx do |t|
            t.input do |i|
              i.prev_out(tx_id, position, input_script.htb, input_amount, 0)
              i.signature_key(key)
            end
            t.output do |o|
              o.value output_amount
              o.script do |s|
                s.recipient(key.addr)
              end
            end
            t.output do |o|
              o.value 0
              o.to(script, :custom)
            end
          end
          token.to_json = tx.to_json
          token.raw = tx.to_payload.bth
          token
        end

        # Create the transaction to broadcast in order to send amount between tokens.
        #
        # @param tx_id [String] Transaction hash.
        # @param position [Number] Transaction index of output.
        # @param input_script [String] ScriptPubKey from input.
        # @param input_amount [Number] Total amount from transaction input.
        # @param output_amount [Number] Amount to send to output, should be enough for feed.
        # @param output_amount_to_addr2 [Number] Amount to send to the output address to receive the tokens, should be low enough for feed.
        # @param addr2 [String] Address to receive the tokens.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def self.send_amount(tx_id, position, input_script, input_amount, output_amount, output_amount_to_addr2, addr2, key, script)
          token = self.new
          tx = build_tx do |t|
            t.input do |i|
              i.prev_out(tx_id, position, input_script.htb, input_amount, 0)
              i.signature_key(key)
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
                s.recipient(key.addr)
              end
            end
            t.output do |o|
              o.value 0
              o.to(script, :custom)
            end
          end
          token.to_json = tx.to_json
          token.raw = tx.to_payload.bth
          token
        end
      end
    end
  end
end
