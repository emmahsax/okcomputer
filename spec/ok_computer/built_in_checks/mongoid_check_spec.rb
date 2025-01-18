require "rails_helper"

# Stubbing the constant out; will exist in apps which have Mongoid loaded
module Mongoid
  module Sessions
  end
end

module OkComputer
  describe MongoidCheck do

    let(:stats) { { "db" => "foobar" } }
    let(:session) { double(:session) }

    it "is a Check" do
      expect(subject).to be_a Check
    end

    describe "#initialize" do
      before do
        allow(Mongoid).to receive(:sessions)
      end

      it "uses the default session by default" do
        expect(Mongoid::Sessions).to receive(:with_name).with(:default).and_return(session)
        expect(subject.session).to eq(session)
      end

      it "accepts a session name" do
        other_session = double("other session")
        expect(Mongoid::Sessions).to receive(:with_name).with(:other_session).and_return(other_session)
        check = described_class.new(:other_session)
        expect(check.session).to eq(other_session)
      end

      it "does not set session if not configured" do
        expect(Mongoid::Sessions).to receive(:with_name).with(:default).and_raise(StandardError)
        expect(subject.session).to eq(nil)
      end
    end

    describe "#check" do
      let(:mongodb_name) { "foo" }
      let(:error_message) { "Error message" }

      context "with a successful connection" do
        before do
          expect(subject).to receive(:mongodb_name) { mongodb_name }
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "Connected to mongodb #{mongodb_name}" }
      end

      context "with an unsuccessful connection" do
        before do
          expect(subject).to receive(:mongodb_name).and_raise(MongoidCheck::ConnectionFailed, error_message)
        end

        it {is_expected.not_to be_successful_check }
        it {is_expected.to have_message "Error: '#{error_message}'" }
      end

      context "when session not configured" do
        before do
          allow(Mongoid).to receive(:sessions)
          expect(Mongoid::Sessions).to receive(:with_name).with(:default).and_raise(StandardError)
        end

        it {is_expected.not_to be_successful_check }

        expected_message = if RUBY_VERSION.to_f >= 3.4
          "Error: 'undefined method 'database' for module Mongoid'"
        elsif RUBY_VERSION.to_f >= 3.3
          "Error: 'undefined method `database' for module Mongoid'"
        else
          "Error: 'undefined method `database' for Mongoid:Module"
        end

        it {is_expected.to have_message expected_message }
      end
    end

    describe "#mongodb_name" do
      it "returns the name of the mongodb" do
        expect(subject).to receive(:mongodb_stats) { stats }
        expect(subject.mongodb_name).to eq(stats["db"])
      end
    end

    describe "#mongodb_stats" do

      context "Mongoid 3" do

        before do
          allow(Mongoid).to receive(:sessions)
        end

        it "returns a mongodb stats hash" do
          expect(session).to receive(:command).with(dbStats: 1) { stats }
          expect(Mongoid::Sessions).to receive(:with_name).with(:default) { session }
          expect(subject.mongodb_stats).to eq(stats)
        end
      end

      context "Mongoid 2" do

        let(:database) { double(:database) }

        it "returns a mongodb stats hash" do
          expect(database).to receive(:stats) { stats }
          expect(Mongoid).to receive(:database) { database }
          expect(subject.mongodb_stats).to eq(stats)
        end
      end
    end
  end
end
