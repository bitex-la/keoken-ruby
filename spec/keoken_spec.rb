require 'spec_helper'

describe Keoken do
  it 'has a version number' do
    expect(Keoken::VERSION).not_to be nil
  end

  it 'defines keoken constants' do
    expect(Keoken::PREFIX_SIZE).not_to be nil
    expect(Keoken::PREFIX).not_to be nil
    expect(Keoken::VERSION_NODE).not_to be nil
    expect(Keoken::TYPE_CREATE_ASSET).not_to be nil
    expect(Keoken::TYPE_SEND_TOKEN).not_to be nil
    expect(Keoken::PREFIX_BYTE_AMOUNT).not_to be nil
    expect(Keoken::AMOUNT_SIZE).not_to be nil
    expect(Keoken::PREFIX_BYTE_ASSET_ID).not_to be nil
    expect(Keoken::ASSET_ID_SIZE).not_to be nil
  end

  it 'creates the test-keoken token' do
    token = Keoken::Token.new(name: 'test-keoken')
    token.create(1_000_000)
    expect(token.hex).to(
      eq('6a0400004b501800000000746573742d6b656f6b656e000000000001000000')
    )
  end

  it 'raise an error when name is not provided' do
    token = Keoken::Token.new
    expect { token.create(1_000_000) }.to raise_error(Keoken::NameNotFound)
  end

  it 'raise an error when id is not provided' do
    token = Keoken::Token.new
    expect { token.send_amount(1_000_000) }.to raise_error(Keoken::IdNotFound)
  end

  it 'send 1_000_000 to token with 34 id' do
    token = Keoken::Token.new(id: 34)
    token.send_amount(1_000_000)
    expect(token.hex).to(
      eq('6a0400004b501000000001000000340000000001000000')
    )
  end

  describe 'creates token' do
    before(:each) do
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
      @transaction_token = Keoken::Transaction::Token.create(tx_id, position, input_script, input_amount, output_amount, key, script)
    end

    it 'format to_json' do
      json = JSON.parse(@transaction_token.to_json)
      expect(json['out']).to(
        eq(
          [
            {
              "value" => "4.99910000",
              "scriptPubKey" => "OP_DUP OP_HASH160 7bb97684cc43e2f8ea0ed1d50dddce3ebf800638 OP_EQUALVERIFY OP_CHECKSIG"
            },
            {
              "value" => "0.00000000",
              "scriptPubKey" => "OP_RETURN 00004b50 00000000746573742d6b656f6b656e000000000001000000"
            }
          ]
        )
      )
    end

    it 'raw transaction' do
      raw = @transaction_token.raw
      expect(raw).to start_with('01000000016ef955ef813fd167438ef35d862d9dcb299672b22ccbc20da598f5ddc59d69aa00000000')
      expect(raw).to end_with('6a0400004b501800000000746573742d6b656f6b656e00000000000100000000000000')
    end

    it 'broadcast transaction' do
      stub_request(:post, 'http://tbch.blockdozer.com:443/insight-api/tx/send')
        .with(:body => {"rawtx"=> /01000000016ef955ef813fd167438ef35d862d9dcb/},
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Host' => 'tbch.blockdozer.com',
              'User-Agent' => 'Ruby'
            })
        .to_return(status: 200, body: '', headers: {})
      transaction = Keoken::Bitprim::Transaction.new(@transaction_token.raw)
      expect(transaction.send_tx).to be_nil
    end
  end
end
