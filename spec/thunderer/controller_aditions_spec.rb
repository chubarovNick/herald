require 'spec_helper'
require 'action_controller'
require 'thunderer/controller_additions'


describe Thunderer::ControllerAdditions do
  class MyController < ActionController::Base
    include Thunderer::ControllerAdditions

    def index
      # render text: 'ok'
    end

    def params; end
  end

  let(:controller_class) { MyController }

  describe '#thunderer_channels' do

      it 'should affect channels class variable' do
        controller_class.thunderer_channels('hello')
        expect(controller_class.channels).to include('hello')
      end

      it 'should affect interpolation_object of class' do
        controller_class.thunderer_channels(object: 'hello')
        expect(controller_class.interpolation_object).to include('hello')
      end

      it 'should setup before filter for setting headers' do
        expect(controller_class).to have_filters(:before, :add_channels_header)
      end

      context 'for instance of controller' do
        subject(:controller) { controller_class.new }

        # it 'should add special header for index response' do
        #   controller_class.thunderer_channels('hello')
        #   allow(controller).to receive(:headers)
        #   controller.send(:add_channels_header)
        # end

      end

  end

end
