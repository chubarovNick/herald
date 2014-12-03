require 'spec_helper'
require 'thunderer/messages/async_message'
require 'rails/all'
describe Thunderer::Messages::AsyncMessage do
  let(:message) { Thunderer::Messages::AsyncMessage.new }
  before { Thunderer.reset_config }

  describe Thunderer::Messages::AsyncMessage::Job do
    let(:job) { Thunderer::Messages::AsyncMessage::Job }
    describe '#queue_adapter' do
      subject { job.queue_adapter }

      context 'when no config' do
        it { is_expected.to eq(ActiveJob::QueueAdapters::InlineAdapter) }
      end

      context 'when active job config set to sucker_punch' do
        around do |ex|
          ActiveJob::Base.queue_adapter = :sucker_punch
          ex.run
          ActiveJob::Base.queue_adapter = :inline
        end

        it { is_expected.to eq(ActiveJob::QueueAdapters::SuckerPunchAdapter) }
      end

      context 'but thunderer config is sucker_punch' do
        before do
          Thunderer.configure do |config|
            config.queue_adapter = :sucker_punch
          end
        end

        context 'and active job config is inline' do
          before { ActiveJob::Base.queue_adapter = :inline }

          it { is_expected.to eq(ActiveJob::QueueAdapters::SuckerPunchAdapter) }

        end
      end
    end
  end


end