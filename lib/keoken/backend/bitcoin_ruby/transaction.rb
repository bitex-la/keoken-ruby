module Keoken
  module Backend
    module BitcoinRuby
      class Transaction
        attr_accessor :to_json, :raw
        extend Bitcoin::Builder

        # Create the transaction to broadcast in order to create tokens.
        #
        # @param address [String] Address that will contain the token.
        # @param key [Bitcoin::Key] The key obtained from Bitcoin Ruby.
        # @param script [String] The token script.
        #
        # @return [Keoken::Backend::BitcoinRuby::Transaction] An object instanciated with the transaction to broadcast.
        #
        def self.build_for_creation(address, key, script)
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
        def self.build_for_send_amount(address, address_dest, key, script)
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
        def self.build(address, addr2, key, script, type)
          bitprim_transaction = Keoken::Bitprim::Transaction.new
          utxos = bitprim_transaction.utxos(address)
          inputs = []
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
            inputs.push(
              tx_id: txid,
              position: output['n'],
              input_script: output['scriptPubKey']['hex'],
              input_amount: output['value'].sub!(/\./, '').sub!(/^0+/, '').to_i
            )
          end
          total = inputs.map { |input| input[:input_amount].to_i }.inject(:+)
          estimate_fee = bitprim_transaction.estimate_fee.to_f
          fee = ((10 + 149 * inputs.length + 35 * output_length(type)) * estimate_fee).to_s.sub!(/\./, '').sub!(/^0+/, '')
          case type
          when :create
            output_amount = total - fee.to_i
            create(inputs, output_amount, key.addr, key, script)
          when :send
            output_amount = total - (fee.to_i * 2)
            output_amount_to_addr2 = fee.to_i
            send_amount(inputs, output_amount, key.addr, output_amount_to_addr2, addr2, key, script)
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
        def self.create(inputs, output_amount, output_address, key, script)
          token = new
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
          token.to_json = tx.to_json
          token.raw = tx.to_payload.bth
          token
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
        def self.send_amount(inputs, output_amount, output_address, output_amount_to_addr2, addr2, key, script)
          token = self.new
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
          token.to_json = tx.to_json
          token.raw = tx.to_payload.bth
          token
        end

        def self.output_length(type)
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
end
