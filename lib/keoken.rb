require 'bitcoin'

require 'keoken/asset'
require 'keoken/token'

module Keoken
  PREFIX_SIZE = '04'
  PREFIX = '00004b50'
  VERSION = '0000'
  TYPE_CREATE_ASSET = '0000'
  TYPE_SEND_TOKEN = '0001'
  PREFIX_BYTE_AMOUNT = '0000000000000000'
  AMOUNT_SIZE = 16
  PREFIX_BYTE_ASSET_ID = '00000000'
  ASSET_ID_SIZE = 8
end