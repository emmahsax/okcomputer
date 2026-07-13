require "rails_helper"

# Stubbing the constant out; will exist in apps which have SolidQueue loaded
module SolidQueue
  class Queue; end
end

module OkComputer
  describe SolidQueueBackedUpCheck do
    let(:queue) { "default" }
    let(:threshold) { 100 }

    subject { SolidQueueBackedUpCheck.new(queue, threshold) }

    it "is a Check" do
      expect(subject).to be_a Check
    end

    context ".new(queue, threshold)" do
      it "accepts a queue name and a threshold to consider backed up" do
        expect(subject.queue).to eq(queue)
        expect(subject.threshold).to eq(threshold)
      end

      it "coerces the threshold parameter into an integer" do
        expect(SolidQueueBackedUpCheck.new(queue, "123").threshold).to eq(123)
      end
    end

    context "#check" do
      context "with the count less than the threshold" do
        before do
          allow(subject).to receive(:size) { threshold - 1 }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue queue '#{queue}' at reasonable level (#{subject.size})" }
      end

      context "with the count equal to the threshold" do
        before do
          allow(subject).to receive(:size) { threshold }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "SolidQueue queue '#{queue}' at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before do
          allow(subject).to receive(:size) { threshold + 1 }
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "SolidQueue queue '#{queue}' is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end
    end

    context "#size" do
      it "defers to SolidQueue::Queue for the ready job count" do
        solid_queue = double("SolidQueue::Queue", size: 42)
        expect(SolidQueue::Queue).to receive(:new).with(queue).and_return(solid_queue)
        expect(subject.size).to eq(42)
      end
    end
  end
end
