# Keoken [![Build Status](https://travis-ci.org/bitex-la/keoken-ruby.svg?branch=master)](https://travis-ci.org/bitex-la/keoken-ruby)

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
token = Keoken::Token.new(name: 'test-keoken')
token.create(1_000_000)
tx_id = 'aa699dc5ddf598a50dc2cb2cb2729629cb9d2d865df38e4367d13f81ef55f96e'
input_script = '76a9147bb97684cc43e2f8ea0ed1d50dddce3ebf80063888ac'
position = 0
script = token.hex
input_amount = 5_0000_0000
output_amount = 4_9991_0000
key = Bitcoin::Key.from_base58("cShKfHoHVf6iKKZym18ip1MJFQFxJwbcLxW53MQikxdDsGd2oxBU")
@transaction_token = Keoken::Backend::BitcoinRuby::Transaction.create(tx_id,
                                                                      position,
                                                                      input_script,
                                                                      input_amount,
                                                                      output_amount,
                                                                      key,
                                                                      script)
transaction = Keoken::Bitprim::Transaction.new(@transaction_token.raw)
transaction.send_tx
```

### Send token money and send transaction to the blockchain

```ruby
Bitcoin.network = :testnet3
transaction = Keoken::Bitprim::Transaction.new
data = transaction.get_assets_by_address('mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDAs')
token = Keoken::Token.new(id: data[0]['asset_id'])
token.send_amount(500_000)
tx_id = 'aa699dc5ddf598a50dc2cb2cb2729629cb9d2d865df38e4367d13f81ef55f96e'
input_script = '76a9147bb97684cc43e2f8ea0ed1d50dddce3ebf80063888ac'
position = 0
script = token.hex
input_amount = 5_0000_0000
output_amount = 4_9991_0000
output_amount_address = 20_000
output_address = 'mnTd41YZ1e1YqsaPNJh3wkeSUrFvp1guzi'
key = Bitcoin::Key.from_base58("cShKfHoHVf6iKKZym18ip1MJFQFxJwbcLxW53MQikxdDsGd2oxBU")
@transaction_token = Keoken::Backend::BitcoinRuby::Transaction.send_amount(tx_id,
                                                                           position,
                                                                           input_script,
                                                                           input_amount,
                                                                           output_amount,
                                                                           output_amount_address,
                                                                           output_address,
                                                                           key,
                                                                           script)
transaction = Keoken::Bitprim::Transaction.new(@transaction_token.raw)
transaction.send_tx
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bitex-la/keoken-ruby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
