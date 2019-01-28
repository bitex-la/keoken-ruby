require 'yaml'
require 'net/http'

module Keoken
  module Bitprim
    class Transaction
      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end

      def send_tx
        uri = URI("#{root_url}tx/send")
        req = Net::HTTP::Post.new(uri)
        req.set_form_data(rawtx: @raw)

        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end

        return res.value if res != Net::HTTPSuccess
      end

      private

      def root_url
        file = YAML.load_file('lib/keoken/bitprim/config.yaml')
        if ENV['KEOKEN_NODE'] == 'PRODUCTION'
          file['Bitprim']['node']['mainnet']['url']
        else
          file['Bitprim']['node']['testnet']['url']
        end
      end
    end
  end
end
