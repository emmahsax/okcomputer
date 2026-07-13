require "rails_helper"

# Stubbing the constant out; will exist in apps which have SolidQueue loaded
module SolidQueue
  class FailedExecution; end
end

module OkComputer
  describe SolidQueueFailedJobsCheck do
    let(:threshold) { 100 }

    subject { SolidQueueFailedJobsCheck.new(threshold) }

    it "is a Check" do
      expect(subject).to be_a Check
    end

    context ".new(threshold)" do
      it "accepts a threshold to consider over the limit" do
        expect(subject.threshold).to eq(threshold)
      end

      it "coerces the threshold parameter into an integer" do
        expect(SolidQueueFailedJobsCheck.new("123").threshold).to eq(123)
      end
    end

    context "#check" do
      context "with the count less than the threshold" do
        before do
          allow(subject).to receive(:size) { threshold - 1 }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue Failed Jobs at reasonable level (#{subject.size})" }
      end

      context "with the count equal to the threshold" do
        before do
          allow(subject).to receive(:size) { threshold }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue Failed Jobs at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before do
          allow(subject).to receive(:size) { threshold + 1 }
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "SolidQueue Failed Jobs is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end
    end

    context "#size" do
      it "defers to SolidQueue for the failed job count" do
        expect(SolidQueue::FailedExecution).to receive(:count) { 123 }
        expect(subject.size).to eq(123)
      end
    end
  end
end
