require 'active_job'
module Thunderer
  module Messages
    class AsyncMessage
      class Job < ::ActiveJob::Base

        class << self
          def queue_adapter
            if Thunderer.config.queue_adapter
              "ActiveJob::QueueAdapters::#{Thunderer.config.queue_adapter.to_s.camelize}Adapter".constantize
            else
              super
            end
          end
        end

        def perform(message)
          Thunderer::Messages::Base.new(message).deliver
        end
      end

      def initialize(message)
        @message = message
      end

      def deliver
        Job.perform_later(@message)
      end

    end
  end
end