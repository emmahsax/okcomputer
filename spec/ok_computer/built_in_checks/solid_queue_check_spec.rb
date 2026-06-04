require "rails_helper"

# Stubbing the constants out; these will exist in apps which have SolidQueue loaded
module SolidQueue
  def self.process_alive_threshold
    5.minutes
  end

  class Process; end
  class ReadyExecution; end
  class ScheduledExecution; end
  class ClaimedExecution; end
  class FailedExecution; end
end

module OkComputer
  describe SolidQueueCheck do
    it "is a Check" do
      expect(subject).to be_a Check
    end

    context "#check" do
      context "when workers and a dispatcher are alive" do
        before do
          allow(subject).to receive(:live_workers).and_return(2)
          allow(subject).to receive(:live_dispatchers).and_return(1)
          allow(subject).to receive(:stats).and_return("ready: 0, scheduled: 0, in progress: 0, failed: 0")
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue is up (2 worker(s), 1 dispatcher(s) alive)." }
        it { is_expected.to have_message "Job Counts: ready: 0, scheduled: 0, in progress: 0, failed: 0" }
      end

      context "when no workers are alive" do
        before do
          allow(subject).to receive(:live_workers).and_return(0)
          allow(subject).to receive(:stats).and_return("ready: 5, scheduled: 0, in progress: 0, failed: 0")
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "SolidQueue is DOWN. No workers are alive." }
      end

      context "when workers are alive but the dispatcher is down" do
        before do
          allow(subject).to receive(:live_workers).and_return(2)
          allow(subject).to receive(:live_dispatchers).and_return(0)
          allow(subject).to receive(:stats).and_return("ready: 0, scheduled: 9, in progress: 0, failed: 0")
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "SolidQueue dispatcher is DOWN. Scheduled jobs will not run." }
      end

      context "when an error occurs" do
        before do
          allow(subject).to receive(:live_workers).and_raise(StandardError, "boom")
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "Error: 'boom'" }
      end
    end

    context "#live_workers" do
      it "counts worker processes with a recent heartbeat" do
        relation = double("relation")
        expect(SolidQueue::Process).to receive(:where).with("last_heartbeat_at > ?", anything).and_return(relation)
        expect(relation).to receive(:where).with(kind: "Worker").and_return(relation)
        expect(relation).to receive(:count).and_return(3)

        expect(subject.live_workers).to eq(3)
      end
    end

    context "#live_dispatchers" do
      it "counts dispatcher processes with a recent heartbeat" do
        relation = double("relation")
        expect(SolidQueue::Process).to receive(:where).with("last_heartbeat_at > ?", anything).and_return(relation)
        expect(relation).to receive(:where).with(kind: "Dispatcher").and_return(relation)
        expect(relation).to receive(:count).and_return(1)

        expect(subject.live_dispatchers).to eq(1)
      end
    end

    context "#stats" do
      it "summarizes the current job counts" do
        allow(SolidQueue::ReadyExecution).to receive(:count).and_return(4)
        allow(SolidQueue::ScheduledExecution).to receive(:count).and_return(1)
        allow(SolidQueue::ClaimedExecution).to receive(:count).and_return(2)
        allow(SolidQueue::FailedExecution).to receive(:count).and_return(0)

        expect(subject.stats).to eq("ready: 4, scheduled: 1, in progress: 2, failed: 0")
      end
    end
  end
end
