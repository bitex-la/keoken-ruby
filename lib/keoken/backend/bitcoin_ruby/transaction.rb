module Keoken
  module Backend
    module BitcoinRuby
      class Transaction
        attr_accessor :to_json, :raw
        extend Bitcoin::Builder

        def self.create(tx_id, position, input_script, input_amount, output_amount, key, script)
          token = self.new
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
