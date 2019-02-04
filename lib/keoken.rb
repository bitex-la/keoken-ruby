require 'bitcoin'

require 'keoken/extensions/bitcoin/script'
require 'keoken/token'
require 'keoken/parser'
require 'keoken/backend/base'
require 'keoken/backend/bitcoin_ruby/transaction'
require 'keoken/bitprim/transaction'
require 'keoken/errors/id_not_found'
require 'keoken/errors/name_not_found'
require 'keoken/errors/data_not_parsed'

module Keoken
  PREFIX_SIZE = '04'.freeze
  PREFIX = '00004b50'.freeze
  VERSION_NODE = '0000'.freeze
  TYPE_CREATE_ASSET = '0000'.freeze
  TYPE_SEND_TOKEN = '0001'.freeze
  PREFIX_BYTE_AMOUNT = '0000000000000000'.freeze
  AMOUNT_SIZE = 16
  PREFIX_BYTE_ASSET_ID = '00000000'.freeze
  ASSET_ID_SIZE = 8
end
