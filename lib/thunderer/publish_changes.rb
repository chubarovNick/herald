require 'active_support'
module Thunderer
  module PublishChanges
    extend ActiveSupport::Concern

    included do
      after_save :publish_changes

      class << self
        attr_accessor :channels, :options, :block
      end

      private

      def publish_changes
        (self.class.channels || []).each do |channel|
          rooted_message = if message_root?
                             Hash[message_root, notification_message]
                           else
                             notification_message
                           end
          Thunderer.publish_to Thunderer::Parser.interpolate_channel(channel, self), rooted_message
        end
      end

      def notification_message
        block = self.class.block
        block ? block.call(self) : self
      end

      def message_root
        self.class.options[:message_root]
      end

      def message_root?
        message_root.present?
      end

    end

    module ClassMethods
      def notify_client_to_channels *args, &block
        @options = args.extract_options!
        @options.assert_valid_keys(:message_root)
        @channels = args
        @block = block
      end
    end

  end
end
