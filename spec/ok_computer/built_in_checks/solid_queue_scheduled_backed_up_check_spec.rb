require "rails_helper"

# Stubbing the constant out; will exist in apps which have SolidQueue loaded
module SolidQueue
  class ScheduledExecution; end
end

module OkComputer
  describe SolidQueueScheduledBackedUpCheck do
    let(:threshold) { 0 }

    subject { SolidQueueScheduledBackedUpCheck.new(threshold) }

    it "is a Check" do
      expect(subject).to be_a Check
    end

    context ".new(threshold, grace:)" do
      it "accepts a threshold and defaults the grace period to 1 minute" do
        expect(subject.threshold).to eq(threshold)
        expect(subject.grace).to eq(1.minute)
      end

      it "coerces the threshold parameter into an integer" do
        expect(SolidQueueScheduledBackedUpCheck.new("5").threshold).to eq(5)
      end

      it "accepts a custom grace period" do
        expect(SolidQueueScheduledBackedUpCheck.new(0, grace: 10.minutes).grace).to eq(10.minutes)
      end
    end

    context "#check" do
      context "with the count less than or equal to the threshold" do
        before { allow(subject).to receive(:size) { threshold } }

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue overdue scheduled jobs at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before { allow(subject).to receive(:size) { threshold + 3 } }

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "SolidQueue overdue scheduled jobs is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end
    end

    context "#size" do
      it "counts scheduled jobs overdue by more than the grace period" do
        relation = double("relation", count: 7)
        expect(SolidQueue::ScheduledExecution).to receive(:where).with("scheduled_at <= ?", anything).and_return(relation)

        expect(subject.size).to eq(7)
      end
    end
  end
end
