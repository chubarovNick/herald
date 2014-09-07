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

  describe '#post' do
    subject { messanger.post(message) }

    context 'with default config' do
      let(:message) { double(:message) }

      specify do
        expect { subject }.to raise_error Thunderer::Messanger::ConfigurationError
      end

    end

    context 'with correct config' do
      before { Thunderer::Messanger.configure('http://localhost:3000') }
      let(:http_form) { double(:form) }
      let(:http) { double(:http) }
      let(:message) { 'Hello world' }
      before { allow(Net::HTTP::Post).to receive(:new).with('/').and_return(http_form) }
      before { allow(Net::HTTP).to receive(:new).with('localhost', 3000).and_return(http) }
      before { allow(http).to receive(:use_ssl=) }


      specify do
        expect(http_form).to receive(:set_form_data).with(message: message.to_json)
        expect(http).to receive(:start).and_yield(http)
        expect(http).to receive(:request).with(http_form).and_return(:result)
        expect(subject).to eq(:result)
      end

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
