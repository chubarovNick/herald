require 'active_support'
module Thunderer
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      cattr_accessor :channels, :interpolation_object

      before_action :add_channels_header,only: [:index]

      private

      def add_channels_header
          headers['channels'] = (self.class.channels || []).map do |channel|
          new_str = if self.class.interpolation_object && channel
                      object = send(self.class.interpolation_object)
                      Thunderer::Parser.interpolate_channel channel, object
                    else
                      channel
                    end
          Thunderer.subscription(channel: new_str)
        end.to_json
      end
    end

    module ClassMethods

      def thunderer_channels(*args)
        options = args.extract_options!
        options.assert_valid_keys(:object)
        self.interpolation_object = options[:object]
        self.channels             = Array.wrap(args)
      end

    end

  end
end
