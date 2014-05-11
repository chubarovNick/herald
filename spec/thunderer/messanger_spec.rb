require 'spec_helper'
require 'thunderer/messanger'

describe Thunderer::Messanger do
  let(:messanger) { Thunderer::Messanger }
  before { Thunderer::Messanger.reset_config }

  it 'default have nil uri' do
    expect(messanger.config['uri']).to eq(nil)
  end

  it 'default have nil use_ssl' do
    expect(messanger.config['use_ssl']).to eq(nil)
  end

  context 'with default config' do

    it 'should raise error when you try post message' do
      message = double(:message)
      expect {
        messanger.post(message)
      }.to raise_error Thunderer::Messanger::ConfigurationError
    end

  end

  describe '#configure' do

    it 'parse url and set configuration' do
      messanger.configure('http://google.ru')
      expect(messanger.config).not_to eq({})
    end

    it 'set use_ssl to false for http' do
      messanger.configure('http://google.ru')
      expect(messanger.config['use_ssl']).to eq(false)
    end

    it 'set use_ssl to false for https' do
      messanger.configure('https://google.ru')
      expect(messanger.config['use_ssl']).to eq(true)
    end

  end

end
