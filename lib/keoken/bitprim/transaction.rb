require 'json'
require 'yaml'
require 'net/http'

module Keoken
  module Bitprim
    class Transaction
      def send_tx(raw)
        uri = URI("#{root_node_url}/tx/send")
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(rawtx: raw)

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        response.value
      end

      def get_assets_by_address(address)
        uri = URI("#{root_keoken_url}/get_assets_by_address")
        params = { address: address }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)

        JSON.parse(response.body.tr('\'', '"'))
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
