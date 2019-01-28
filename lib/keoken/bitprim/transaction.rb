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
        uri = URI("#{root_node_url}tx/send")
        req = Net::HTTP::Post.new(uri)
        req.set_form_data(rawtx: @raw)

        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end

        return res.value if res != Net::HTTPSuccess
      end

      def get_assets_by_address(address)
        uri = URI(root_keoken_url)
        params = { address: address }
        request = Net::HTTP::Get.new(uri)
        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request request
        end

        res.body
      end

      private

      def root_node_url
        file = YAML.load_file('lib/keoken/bitprim/config.yaml')
        if ENV['KEOKEN_NODE'] == 'PRODUCTION'
          file['Bitprim']['node']['mainnet']['url']
        else
          file['Bitprim']['node']['testnet']['url']
        end
      end

      def root_keoken_url
        file = YAML.load_file('lib/keoken/bitprim/config.yaml')
        if ENV['KEOKEN_NODE'] == 'PRODUCTION'
          file['Bitprim']['keoken']['mainnet']['url']
        else
          file['Bitprim']['keoken']['testnet']['url']
        end
      end
    end
  end
end
