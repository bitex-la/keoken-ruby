require "spec_helper"

describe Keoken do
  it "has a version number" do
    expect(Keoken::VERSION).not_to be nil
  end

  it "defines keoken constants" do
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

  it "creates the test-keoken token" do
    token = Keoken::Token.new(name: "test-keoken")
    token.create(1_000_000)
    expect(token.hex).to(
      eq("6a0400004b501800000000746573742d6b656f6b656e000000000001000000")
    )
  end

  it "raise an error when name is not provided" do
    token = Keoken::Token.new
    expect { token.create(1_000_000) }.to raise_error(Keoken::NameNotFound)
  end

  it "raise an error when id is not provided" do
    token = Keoken::Token.new
    expect { token.send_amount(1_000_000) }.to raise_error(Keoken::IdNotFound)
  end

  it "send 1_000_000 to token with 34 id" do
    token = Keoken::Token.new(id: 34)
    token.send_amount(1_000_000)
    expect(token.hex).to(
      eq("6a0400004b501000000001000000340000000001000000")
    )
  end

  describe "creates token" do
    before(:each) do
      mock_requests
      Bitcoin.network = :testnet3
      token = Keoken::Token.new(name: 'test-keoken')
      token.create(1_000_000)
      key = Bitcoin::Key.from_base58('cShKfHoHVf6iKKZym18ip1MJFQFxJwbcLxW53MQikxdDsGd2oxBU')
      script = token.hex
      @transaction_token = Keoken::Backend::BitcoinRuby::Transaction.build_for_creation(key.addr, key, script)
    end

    it "format to_json" do
      json = JSON.parse(@transaction_token.to_json)
      expect(json["out"]).to(
        eq(
          [
            {
              "value" => "0.08752190",
              "scriptPubKey" => "OP_DUP OP_HASH160 7bb97684cc43e2f8ea0ed1d50dddce3ebf800638 OP_EQUALVERIFY OP_CHECKSIG",
            },
            {
              "value" => "0.00000000",
              "scriptPubKey" => "OP_RETURN 00004b50 00000000746573742d6b656f6b656e000000000001000000",
            },
          ]
        )
      )
    end

    it "raw transaction" do
      raw = @transaction_token.raw
      expect(raw).to start_with("0100000001dae8143d5422d5e1018c43732baa74ac3114d4399a1f58a9ea7e31f656938a44010000006")
      expect(raw).to end_with("6a0400004b501800000000746573742d6b656f6b656e00000000000100000000000000")
    end

    it "broadcast transaction" do
      stub_request(:post, "https://tbch.blockdozer.com/insight-api/tx/send")
        .with(:body => {"rawtx" => /0100000001dae8143d5422d5e1018c43732baa74ac3114d4399a1f58a9ea7e31f656938a44010000006/},
              headers: {
                "Accept" => "*/*",
                "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                "Content-Type" => "application/x-www-form-urlencoded",
                "Host" => "tbch.blockdozer.com",
                "User-Agent" => "Ruby",
              })
        .to_return(status: 200, body: "{\"txid\":\"f410c773d079327b8283c175b08a84faa6ffcfbde40b5939b85f07f0dfde2eb8\"}", headers: {})
      transaction = Keoken::Bitprim::Transaction.new
      expect(transaction.send_tx(@transaction_token.raw)).to eq({"txid" => "f410c773d079327b8283c175b08a84faa6ffcfbde40b5939b85f07f0dfde2eb8"})
    end
  end

  describe "send money token" do
    before(:each) do
      mock_requests
      Bitcoin.network = :testnet3
      bitprim_transaction = Keoken::Bitprim::Transaction.new
      assets = bitprim_transaction.assets_by_address('mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA')
      token = Keoken::Token.new(id: assets.first['asset_id'])
      token.send_amount(500_000)
      key = Bitcoin::Key.from_base58('cShKfHoHVf6iKKZym18ip1MJFQFxJwbcLxW53MQikxdDsGd2oxBU')
      script = token.hex
      @transaction_token = Keoken::Backend::BitcoinRuby::Transaction.build_for_send_amount(key.addr, 'mnTd41YZ1e1YqsaPNJh3wkeSUrFvp1guzi', key, script)
    end

    it "format to_json" do
      json = JSON.parse(@transaction_token.to_json)
      expect(json["out"]).to(
        eq(
          [
            {
              "value" => "0.00269544",
              "scriptPubKey" => "OP_DUP OP_HASH160 4c2791f07c046ef21d688f12296f91ad7b44d2bb OP_EQUALVERIFY OP_CHECKSIG",
            },
            {
              "value" => "0.08446911",
              "scriptPubKey" => "OP_DUP OP_HASH160 7bb97684cc43e2f8ea0ed1d50dddce3ebf800638 OP_EQUALVERIFY OP_CHECKSIG",
            },
            {
              "value" => "0.00000000",
              "scriptPubKey" => "OP_RETURN 00004b50 00000001000001230000000000500000",
            },
          ]
        )
      )
    end

    it "raw transaction" do
      raw = @transaction_token.raw
      expect(raw).to start_with("0100000001dae8143d5422d5e1018c43732baa74ac3114d4399a1f58a9ea7e31f656938a4401000000")
      expect(raw).to end_with("6a0400004b50100000000100000123000000000050000000000000")
    end
  end
end

def mock_requests
  body_request = "[{\"address\":\"mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA\",\"txid\":\"448a9356f6317eeaa9581f9a39d41431ac74aa2b73438c01e1d522543d14e8da\",\"vout\":1,\"scriptPubKey\":\"76a9147bb97684cc43e2f8ea0ed1d50dddce3ebf80063888ac\",\"amount\":0.08985999,\"satoshis\":8985999,\"height\":1282589,\"confirmations\":1356}]"
  stub_request(:get, "https://tbch.blockdozer.com/insight-api/addr/mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA/utxo").
    with(:headers => {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Host" => "tbch.blockdozer.com",
            "User-Agent" => "Ruby",
          }).
    to_return(:status => 200, :body => body_request, :headers => {})

  body_request = "{\"txid\":\"448a9356f6317eeaa9581f9a39d41431ac74aa2b73438c01e1d522543d14e8da\",\"version\":1,\"locktime\":0,\"vin\":[{\"txid\":\"48c158109ca432e109971ca61e4bccbdc2b51053c02f8183f5ca7f60a55df4d0\",\"vout\":0,\"sequence\":4294967295,\"n\":0,\"scriptSig\":{\"hex\":\"483045022100a64b8798d783d1fb7ea306cfdc2aa09cae972cbfed3fcd92a4501e54035f869b022004da604a3dd52cecd8b89200065b96bdf7c3684e6ec983ed3dceed1bf8d3a480412102bd2af43b8c683f7bb5c5dc4aad7c5a2961252676d85c2547de9767e1a6252455\",\"asm\":\"3045022100a64b8798d783d1fb7ea306cfdc2aa09cae972cbfed3fcd92a4501e54035f869b022004da604a3dd52cecd8b89200065b96bdf7c3684e6ec983ed3dceed1bf8d3a480[ALL|FORKID] 02bd2af43b8c683f7bb5c5dc4aad7c5a2961252676d85c2547de9767e1a6252455\"},\"addr\":\"mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA\",\"valueSat\":9991999,\"value\":0.09991999,\"doubleSpentTxID\":null}],\"vout\":[{\"value\":\"0.01000000\",\"n\":0,\"scriptPubKey\":{\"hex\":\"76a9141a53f3efae04708754ca1c5382085249c0ff597d88ac\",\"asm\":\"OP_DUP OP_HASH160 1a53f3efae04708754ca1c5382085249c0ff597d OP_EQUALVERIFY OP_CHECKSIG\",\"addresses\":[\"mhvASBxPioT6eLPtSA5u1SNoT49RsME3BJ\"],\"type\":\"pubkeyhash\"},\"spentTxId\":null,\"spentIndex\":null,\"spentHeight\":null},{\"value\":\"0.08985999\",\"n\":1,\"scriptPubKey\":{\"hex\":\"76a9147bb97684cc43e2f8ea0ed1d50dddce3ebf80063888ac\",\"asm\":\"OP_DUP OP_HASH160 7bb97684cc43e2f8ea0ed1d50dddce3ebf800638 OP_EQUALVERIFY OP_CHECKSIG\",\"addresses\":[\"mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA\"],\"type\":\"pubkeyhash\"},\"spentTxId\":null,\"spentIndex\":null,\"spentHeight\":null},{\"value\":\"0.00000000\",\"n\":2,\"scriptPubKey\":{\"hex\":\"6a0400004b501000000001000000170000000000000064\",\"asm\":\"OP_RETURN 1347092480 00000001000000170000000000000064\"},\"spentTxId\":null,\"spentIndex\":null,\"spentHeight\":null}],\"blockhash\":\"0000000000009505e41c238f88f5c9b5591e92f7eb68545962a5dd71cd075525\",\"blockheight\":1282589,\"confirmations\":1356,\"time\":1548360176,\"blocktime\":1548360176,\"valueOut\":0.09985999,\"size\":258,\"valueIn\":0.09991999,\"fees\":0.00006}"
  stub_request(:get, "https://tbch.blockdozer.com/insight-api/tx/448a9356f6317eeaa9581f9a39d41431ac74aa2b73438c01e1d522543d14e8da").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'tbch.blockdozer.com', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => body_request, :headers => {})

  stub_request(:get, "https://tbch.blockdozer.com/insight-api/utils/estimatefee").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'tbch.blockdozer.com', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "{\"2\":0.0001021}", :headers => {})

  body_response = "[{'amount': 100000, 'asset_creator': 'mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA', 'asset_id': 123, 'asset_name': 'keoken-token'}]"
  stub_request(:get, "https://explorer.testnet.keoken.io/api/get_assets_by_address?address=mro9aqn4xCzXVS7jRFFuzT2ERKonvPdSDA")
    .with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Host" => "explorer.testnet.keoken.io",
        "User-Agent" => "Ruby",
      },
    )
    .to_return(status: 200, body: body_response, headers: {})
end
