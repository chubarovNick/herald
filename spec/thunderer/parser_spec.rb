require 'spec_helper'
require 'ostruct'

describe Thunderer::Parser do

  let(:object) { OpenStruct.new(first: 1, second: 2) }

  describe '#interpolate_channel' do
    subject { Thunderer::Parser.interpolate_channel(channel, object) }

    context 'when channel have no interpolation' do
      let(:channel) { 'without interpolation string' }

      it { should == channel }
    end

    context 'when channel have one interpolation sequence' do
      let(:channel) { '/hello/:first' }

      it { should include('1') }

    end

    context 'when channel have two interpolations' do
      let(:channel) { '/hello/:first/world/:second' }

      it { should include('1') }

      it { should include('2') }
    end


  end

end