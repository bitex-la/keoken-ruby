# Keoken [![Build Status](https://travis-ci.org/bitex-la/keoken-ruby.svg?branch=master)](https://travis-ci.org/bitex-la/keoken-ruby) [![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](https://www.rubydoc.info/github/bitex-la/keoken-ruby/master)

Creates BCH tokens and send money between them for the Keoken protocol.

https://www.keoken.io/

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'keoken'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keoken

## Usage

### Create token and send it to the blockchain

```ruby
# It uses bitcoin-ruby, but you can use Trezor or Electrum, the most important command is the script,
# which you can obtain with token.hex,
# then you can send it as an output with a scriptPubKey and a value of 0.
# In order to crate a token you need two outputs,
# the change address with an amount less than original (for fees)
# and the other one for the script. To send money you need three outputs,
# the change address, the address who owns the recipient token and the script.

Bitcoin.network = :testnet3
token = Keoken::Token.new(name: "test-keoken-bitex")
token.create(1_000_000)
key = Bitcoin::Key.from_base58("cShKfHoHVf6iYKZym18ip1MJFQFxJwbcLxW53MQikxdDsGd2ofBU")
script = token.hex
@transaction_token = Keoken::Backend::BitcoinRuby::Transaction.build_for_creation(key.addr, key, script)
transaction = Keoken::Bitprim::Transaction.new
transaction.send_tx(@transaction_token.raw)
```

### Send token money and send transaction to the blockchain

```ruby
Bitcoin.network = :testnet3
bitprim_transaction = Keoken::Bitprim::Transaction.new
assets = bitprim_transaction.assets_by_address('mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA')
token = Keoken::Token.new(id: assets.first['asset_id'])
token.send_amount(500_000)
key = Bitcoin::Key.from_base58('cShKfHoHVf6iKKZym18ip1MJFQFxJwbcLxW53MQikxdDsGd2oxBU')
script = token.hex
@transaction_token = Keoken::Backend::BitcoinRuby::Transaction.build_for_send_amount(key.addr, 'mnTd41YZ1e1YqsaPNJh3wkeSUrFvp1guzi', key, script)
transaction = Keoken::Bitprim::Transaction.new
transaction.send_tx(@transaction_token.raw)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bitex-la/keoken-ruby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
