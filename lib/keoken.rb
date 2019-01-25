require 'bitcoin'

require 'keoken/extensions/bitcoin/script'
require 'keoken/token'
require 'keoken/transaction/token'
require 'keoken/bitprim/transaction'
require 'keoken/errors/id_not_found'
require 'keoken/errors/name_not_found'

module Keoken
  PREFIX_SIZE = '04'
  PREFIX = '00004b50'
  VERSION_NODE = '0000'
  TYPE_CREATE_ASSET = '0000'
  TYPE_SEND_TOKEN = '0001'
  PREFIX_BYTE_AMOUNT = '0000000000000000'
  AMOUNT_SIZE = 16
  PREFIX_BYTE_ASSET_ID = '00000000'
  ASSET_ID_SIZE = 8
end
