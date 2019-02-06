require 'json'
require 'yaml'
require 'net/http'

module Keoken
  module Bitprim
    class Transaction
      # Broadcast a raw transaction.
      #
      # @param raw [String] The raw transaction.
      #
      # @return [String] Value from response.
      #
      def send_tx(raw)
        uri = URI("#{root_node_url}/tx/send")
        response = Net::HTTP.post_form(uri, 'rawtx' => raw)

        case response
        when Net::HTTPSuccess then
          JSON.parse(response.body)
        else
          response.body
        end
      end

      # Get tokens from address.
      #
      # @param address [String] The address that contains the tokens.
      #
      # @return [Array] Detailed info from tokens associated to the address.
      #
      def assets_by_address(address)
        uri = URI("#{root_keoken_url}/get_assets_by_address")
        params = { address: address }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)

        JSON.parse(response.body.tr('\'', '"'))
      end

      # Get utxos from address.
      #
      # @param address [String] The address that contains the utxos.
      #
      # @return [Array] Detailed info from utxos.
      #
      def utxos(address)
        uri = URI("#{root_node_url}/addr/#{address}/utxo")
        response = Net::HTTP.get_response(uri)

        JSON.parse(response.body)
      end

      # Get transaction details from transaction hash.
      #
      # @param txid [String] The transaction id to get the info.
      #
      # @return [Array] Detailed info from transaction.
      #
      def tx(txid)
        uri = URI("#{root_node_url}/tx/#{txid}")
        response = Net::HTTP.get_response(uri)

        JSON.parse(response.body)
      end

      # Get estimate fee.
      #
      # @return [Json] Fee estimated per kb.
      #
      def estimate_fee
        uri = URI("#{root_node_url}/utils/estimatefee")
        response = Net::HTTP.get_response(uri)

        result = JSON.parse(response.body)
        result['2']
      end

      private

      def root_node_url
        file = YAML.load_file(check_for_path)
        if ENV['KEOKEN_NODE'] == 'PRODUCTION'
          file['Bitprim']['node']['mainnet']['url']
        else
          file['Bitprim']['node']['testnet']['url']
        end
      end

      def root_keoken_url
        file = YAML.load_file(check_for_path)
        if ENV['KEOKEN_NODE'] == 'PRODUCTION'
          file['Bitprim']['keoken']['mainnet']['url']
        else
          file['Bitprim']['keoken']['testnet']['url']
        end
      end

      def check_for_path
        path = 'config/keoken.yaml'
        return path if File.file?(path)
        "#{Gem.loaded_specs['keoken'].full_gem_path}/lib/keoken/bitprim/config.yaml"
      end
    end
  end
end
