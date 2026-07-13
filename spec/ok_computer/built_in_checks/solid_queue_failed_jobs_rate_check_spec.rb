require "rails_helper"

# Stubbing the constant out; will exist in apps which have SolidQueue loaded
module SolidQueue
  class FailedExecution; end
end

module OkComputer
  describe SolidQueueFailedJobsRateCheck do
    let(:threshold) { 10 }

    subject { SolidQueueFailedJobsRateCheck.new(threshold) }

    it "is a Check" do
      expect(subject).to be_a Check
    end

    context ".new(threshold, window)" do
      it "accepts a threshold and defaults the window to 300 seconds" do
        expect(subject.threshold).to eq(threshold)
        expect(subject.window).to eq(300)
      end

      it "accepts a custom window" do
        expect(SolidQueueFailedJobsRateCheck.new(threshold, 60).window).to eq(60)
      end

      it "coerces the threshold parameter into an integer" do
        expect(SolidQueueFailedJobsRateCheck.new("123").threshold).to eq(123)
      end
    end

    context "#check" do
      context "with the count less than the threshold" do
        before do
          allow(subject).to receive(:size) { threshold - 1 }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue Failed Jobs Rate at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before do
          allow(subject).to receive(:size) { threshold + 1 }
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "SolidQueue Failed Jobs Rate is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end
    end

    context "#size" do
      it "counts failed executions created within the window" do
        relation = double("relation", count: 7)
        expect(SolidQueue::FailedExecution).to receive(:where).with("created_at > ?", anything).and_return(relation)
        expect(subject.size).to eq(7)
      end

      it "uses a number of seconds to compute the cutoff" do
        now = Time.now
        allow(Time).to receive(:now).and_return(now)
        relation = double("relation", count: 0)
        check = SolidQueueFailedJobsRateCheck.new(threshold, 120)
        expect(SolidQueue::FailedExecution).to receive(:where).with("created_at > ?", now - 120).and_return(relation)
        check.size
      end

      it "accepts an ActiveSupport::Duration window" do
        relation = double("relation", count: 0)
        check = SolidQueueFailedJobsRateCheck.new(threshold, 5.minutes)
        expect(SolidQueue::FailedExecution).to receive(:where).with("created_at > ?", anything).and_return(relation)
        check.size
      end
    end
  end
end
