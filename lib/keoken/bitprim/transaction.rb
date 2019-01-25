require 'yaml'
require 'net/http'

module Keoken
  module Bitprim
    class Transaction
      attr_writer :raw

      def initialize(raw)
        @raw = raw
      end

      def send
        uri = URI("#{root_url}/tx/send")
        req = Net::HTTP::Post.new(uri)
        req.set_form_data(rawtx: @raw)

        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end

        case res
        when Net::HTTPSuccess
          true
        else
          res.value
        end
      end
    end

    private
    def root_url
      file = YAML.load_file('config.yaml')
      if ENV['KEOKEN_NODE'] == 'PRODUCTION'
        file['Bitprim']['node']['mainnet']['url']
      else
        file['Bitprim']['node']['testnet']['url']
      end
    end
  end
end
