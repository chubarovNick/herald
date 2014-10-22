require 'spec_helper'
require 'thunderer/publish_changes'

class DummyClass < ActiveRecord::Base
  include Thunderer::PublishChanges
end

describe Thunderer::PublishChanges do
  let(:dummy_class) { DummyClass }
  let(:dummy) { DummyClass.new }

  context 'when notify_client_to_channels with only channel' do
    before do
      dummy_class.notify_client_to_channels('/channel')
    end

    context 'channels' do
      subject { dummy_class.channels }

      it { is_expected.to eq(['/channel']) }

    end

    context 'callback' do
      before { expect(Thunderer).to receive(:publish_to).with('/channel', dummy) }
      subject { dummy.save }

      it { is_expected.to eq(true) }

    end

  end

  context 'when notify_client_to_channels message_root' do
    before do
      dummy_class.notify_client_to_channels('/channel', message_root: 'root')
    end

    context 'channels' do
      subject { dummy_class.channels }

      it { is_expected.to eq(['/channel']) }

    end

    context 'callback' do
      before { expect(Thunderer).to receive(:publish_to).with('/channel', Hash['root', dummy]) }
      subject { dummy.save }

      it { is_expected.to eq(true) }

    end
  end

  context 'when notify_client_to_channels block' do
    let(:dummy) { DummyClass.find(1)}
    before do
      dummy_class.notify_client_to_channels '/channel' do |object|
        {id: object.id}
      end
    end

    context 'channels' do
      subject { dummy_class.channels }

      it { is_expected.to eq(['/channel']) }

    end

    context 'callback' do
      before { expect(Thunderer).to receive(:publish_to).with('/channel', {id: dummy.id}) }
      subject { dummy.save }

      it { is_expected.to eq(true) }

    end
  end

end