module Thunderer
  module ChannelParser

    class << self
      def interpolate_channel channel, object
        channel.gsub(/:\w*\b/, interpolation_hash(channel, object))
      end

      private

      def interpolation_hash channel, object
        {}.tap do |result|
          channel.scan(/:\w*\b/).map do |interpolation_key|
            object_method   = interpolation_key.gsub(':', '')
            replaced_string = object.send(object_method).to_s
            result[interpolation_key] =  replaced_string
          end
        end
      end
    end
  end
end