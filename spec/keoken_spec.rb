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
end
