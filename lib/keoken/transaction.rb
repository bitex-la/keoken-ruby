require 'extensions/bitcoin/script'

module Keoken
  module Transaction
    class Token
      extend Bitcoin::Builder

      def self.create(tx_id, position, script, input_amount, output_amount, key)
        build_tx do |t|
          t.input do |i| 
            i.prev_out(tx_id, position, script.htb, input_amount, 0)
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
      end

      def self.send(tx_id, position, script, input_amount, output_amount, output_amount_to_addr2, key)
        build_tx do |t|
          t.input do |i| 
            i.prev_out(tx_id, position, script.htb, input_amount, 0)
            i.signature_key(key)
          end
          t.output do |o|
            o.value output_amount_to_addr2
            o.script do |s|
              s.recipient(key2.addr)
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
      end
    end
  end
end
