require 'spec_helper'
require 'ostruct'

describe Thunderer::ChannelParser do

  let(:object) { OpenStruct.new(first: 1, second: 2) }

  describe '#interpolate_channel' do
    subject { Thunderer::ChannelParser.interpolate_channel(channel, object) }

    context 'when channel have no interpolation' do
      let(:channel) { 'without interpolation string' }

      it { is_expected.to  eq(channel) }
    end

    context 'when channel have one interpolation sequence' do
      let(:channel) { '/hello/:first' }

      it { is_expected.to include('1') }

    end

    context 'when channel have two interpolations' do
      let(:channel) { '/hello/:first/world/:second' }

      it { is_expected.to include('1') }

      it { is_expected.to include('2') }
    end


  end

end