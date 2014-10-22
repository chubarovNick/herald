require 'spec_helper'

describe Thunderer do
  before { Thunderer.reset_config }
  let(:config_file_path) { 'spec/fixtures/thunderer.yml' }
  let(:environment) { 'production' }
  let(:load_config) { Thunderer.load_config(config_file_path, environment) }

  describe 'default state' do
    describe '#config' do
      subject { Thunderer.config }

      it { is_expected.to eq({}) }

    end
  end

  describe '#load_config' do

    subject { Thunderer.config }

    context 'when config environment was exists' do
      before { load_config }

      it { is_expected.to include(:server => 'http://example.com/faye') }

      it { is_expected.to include(:secret_token => 'PRODUCTION_SECRET_TOKEN') }

      it { is_expected.to include(:signature_expiration => 600) }
    end

    context 'when config environment was not exists' do
      let(:environment) { 'test' }

      specify do
        expect {
          load_config
        }.to raise_error ArgumentError
      end

    end

    describe 'Thunderer::Messanger configuration' do
      subject { Thunderer::Messanger.config }

      it { is_expected.not_to eq({}) }

      context 'when config have local_server_url' do
        let(:config_file_path) { 'spec/fixtures/thunderer_local_server.yml' }
        let(:environment) { 'production' }

        before { load_config }

        it { is_expected.to include('uri'=>URI.parse('http://localhost:3000')) }

      end

    end

  end

  describe '#subscription' do
    before { load_config }
    let!(:time_mock) { Time.now }
    before { allow(Time).to receive(:now) { time_mock } }
    before { Thunderer.config[:server] = 'server' }
    subject { Thunderer.subscription }

    it { is_expected.to include(:timestamp => (time_mock.to_f * 1000).round) }

    context 'when #subscription pass params' do
      subject { Thunderer.subscription(:timestamp => 123, :channel => 'hello') }

      it { is_expected.to include(:timestamp => 123) }
      it { is_expected.to include(:channel => 'hello') }
      it { is_expected.to include(:server => 'server') }
    end

    describe 'signature' do
      before { Thunderer.config[:secret_token] = 'token' }
      subject { Thunderer.subscription(:timestamp => 123, :channel => 'channel') }

      it { is_expected.to include(:signature => Digest::SHA1.hexdigest('tokenchannel123')) }

    end


  end

  describe '#message' do

    describe 'formatting' do
      let(:secret_token) { 'token' }
      before { Thunderer.config[:secret_token] = secret_token }

      subject { Thunderer.message('chan', :foo => 'bar') }

      it do
        expect(subject).to eq(:ext => {:thunderer_secret_token => 'token'},
                              :channel => 'chan',
                              :data => {
                                  :channel => 'chan',
                                  :data => {:foo => 'bar'}
                              })
      end

    end

  end

  describe '#publish_message' do
    let(:message) { 'foo' }
    subject { Thunderer.publish_message(message) }

    context 'when config are loaded' do
      before { load_config }

      specify do
        expect(Thunderer::Messanger).to receive(:post)
        subject
      end
    end

    context 'when config are not loaded' do
      specify do
        expect { subject }.to raise_error(Thunderer::Error)
      end
    end


  end

  describe '#publish_to' do
    let(:message) { 'foo' }
    let(:channel) { 'channel' }
    subject { Thunderer.publish_to(channel, message) }
    before do
      allow(Thunderer).to receive(:message).with( channel, message) { 'message' }
      allow(Thunderer).to receive(:publish_message).with('message') { :result }
    end

    it { is_expected.to eq(:result)}


  end

  describe '#faye_app' do
    subject { Thunderer.faye_app }

    it { is_expected.to be_kind_of(Faye::RackAdapter) }

  end


  describe 'signature_expired?' do
    let(:expiration) { 30*60 }
    before { Thunderer.config[:signature_expiration] = expiration }
    subject { Thunderer.signature_expired?(time) }

    context 'when time greater than expiration ' do
      let(:time) { Thunderer.subscription[:timestamp] - 31*60*1000 }

      it { is_expected.to eq(true) }

    end

    context 'when time less than expiration' do
      let(:time) { Thunderer.subscription[:timestamp] - 29*60*1000 }

      it { is_expected.to eq(false) }

    end

    context 'when expiration is nil' do
      let(:expiration) { nil }
      let(:time) { 0 }

      it { is_expected.to eq(nil) }

    end

  end

end
