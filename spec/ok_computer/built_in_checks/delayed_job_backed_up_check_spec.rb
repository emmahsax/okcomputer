require "rails_helper"

# Stubbing the constant out; will exist in apps which have
# Delayed Job loaded
module Delayed
  class Job; end
end

module OkComputer
  describe DelayedJobBackedUpCheck do
    let(:priority) { 10 }
    let(:threshold) { 100 }

    subject { DelayedJobBackedUpCheck.new priority, threshold }

    it "is a Check" do
      expect(subject).to be_a Check
    end

    context ".new(priority, threshold)" do
      it "accepts a priority and a threshold to consider backed up" do
        expect(subject.priority).to eq(priority)
        expect(subject.threshold).to eq(threshold)
      end

      it "coerces priority into an integer" do
        expect(DelayedJobBackedUpCheck.new("123", threshold).priority).to eq(123)
      end

      it "coercese threshold into an integer" do
        expect(DelayedJobBackedUpCheck.new(priority, "123").threshold).to eq(123)
      end

      it "sets greater_than_priority to false" do
        expect(DelayedJobBackedUpCheck.new(priority, "123").greater_than_priority).to eq(false)
      end
    end

    context ".new(priority, threshold, :greater_than_priority => true)" do
      it "accepts an options hash, and assigns variables correctly" do
        expect(DelayedJobBackedUpCheck.new(priority, threshold, :greater_than_priority => true).greater_than_priority).to eq(true)
      end
    end

    context "#check" do
      context "when not backed up" do
        before do
          allow(subject).to receive(:size) { 99 }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "Delayed Jobs with priority lower than '#{subject.priority}' at reasonable level (#{subject.size})"}
      end

      context "when backed up" do
        before do
          allow(subject).to receive(:size) { 123 }
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "Delayed Jobs with priority lower than '#{subject.priority}' is #{subject.size - subject.threshold} over threshold! (#{subject.size})"}
      end

      context "with greater_than_priority == true" do
        subject { DelayedJobBackedUpCheck.new priority, threshold , :greater_than_priority =>  true }
        context "when not backed up" do
          before do
            allow(subject).to receive(:size) { 89 }
          end

          it { is_expected.to be_successful_check }
          it { is_expected.to have_message "Delayed Jobs with priority higher than '#{subject.priority}' at reasonable level (#{subject.size})"}
        end

        context "when backed up" do
          before do
            allow(subject).to receive(:size) { 123 }
          end

          it { is_expected.not_to be_successful_check }
          it { is_expected.to have_message "Delayed Jobs with priority higher than '#{subject.priority}' is #{subject.size - subject.threshold} over threshold! (#{subject.size})"}
        end
      end
    end

    context "#size" do

      context "when Mongoid defined" do
        before do
          stub_const('Delayed::Backend::Mongoid::Job', Object.new)
          expect(stub_const('Delayed::Worker', Object.new)).to receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
        end

        it "checks Delayed::Job's count of pending jobs within the given priority" do
          expect(Delayed::Job).to receive(:lte).with({ priority: priority }).and_return(Delayed::Job)
          expect(Delayed::Job).to receive(:where).with({ :locked_at => nil, :last_error => nil }).and_return(Delayed::Job)
          expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
          expect(subject.size).to eq 456
        end
      end

      context "when Mongoid not defined" do
        before { hide_const 'Delayed::Backend::Mongoid::Job' }

        it "checks Delayed::Job's count of pending jobs within the given priority" do
          expect(Delayed::Job).to receive(:where).with("priority <= ?", priority).and_return(Delayed::Job)
          expect(Delayed::Job).to receive(:where).with({ :locked_at => nil, :last_error => nil }).and_return(Delayed::Job)
          expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
          expect(subject.size).to eq 456
        end
      end

      context "with greater_than_priority == true" do
        subject { DelayedJobBackedUpCheck.new priority, threshold, :greater_than_priority => true }
        context "when Mongoid defined" do
          before do
            stub_const('Delayed::Backend::Mongoid::Job', Object.new)
            expect(stub_const('Delayed::Worker', Object.new)).to receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
          end

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:gte).with({ priority: priority }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :locked_at => nil, :last_error => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end

        context "when Mongoid not defined" do
          before { hide_const 'Delayed::Backend::Mongoid::Job' }

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:where).with("priority >= ?", priority).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :locked_at => nil, :last_error => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end
      end

      context "with include_locked == true" do
        subject { DelayedJobBackedUpCheck.new priority, threshold, :include_locked => true }
        context "when Mongoid defined" do
          before do
            stub_const('Delayed::Backend::Mongoid::Job', Object.new)
            expect(stub_const('Delayed::Worker', Object.new)).to receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
          end

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:lte).with({ priority: priority }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :last_error => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end

        context "when Mongoid not defined" do
          before { hide_const 'Delayed::Backend::Mongoid::Job' }

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:where).with("priority <= ?", priority).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :last_error => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end
      end

      context "with include_errored == true" do
        subject { DelayedJobBackedUpCheck.new priority, threshold, :include_errored => true }
        context "when Mongoid defined" do
          before do
            stub_const('Delayed::Backend::Mongoid::Job', Object.new)
            expect(stub_const('Delayed::Worker', Object.new)).to receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
          end

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:lte).with(priority: priority).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :locked_at => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end

        context "when Mongoid not defined" do
          before { hide_const 'Delayed::Backend::Mongoid::Job' }

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:where).with("priority <= ?", priority).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :locked_at => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end
      end

      context "with queue set" do
        subject { DelayedJobBackedUpCheck.new priority, threshold, :queue => 'default' }
        context "when Mongoid defined" do
          before do
            stub_const('Delayed::Backend::Mongoid::Job', Object.new)
            expect(stub_const('Delayed::Worker', Object.new)).to receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
          end

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:lte).with({ priority: priority }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :queue => 'default', :last_error => nil, :locked_at => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end

        context "when Mongoid not defined" do
          before { hide_const 'Delayed::Backend::Mongoid::Job' }

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            expect(Delayed::Job).to receive(:where).with("priority <= ?", priority).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:where).with({ :queue => 'default', :last_error => nil, :locked_at => nil }).and_return(Delayed::Job)
            expect(Delayed::Job).to receive(:count).with(no_args()).and_return(456)
            expect(subject.size).to eq 456
          end
        end
      end
    end
  end
end
