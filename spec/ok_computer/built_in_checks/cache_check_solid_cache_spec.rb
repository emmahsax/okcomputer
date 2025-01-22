require "rails_helper"

module OkComputer
  describe CacheCheckSolidCache do
    let(:stats) do
      {
        connections: 2,
        connection_stats: {
          "shard1" => {
            max_age: 3600,
            oldest_age: 1800,
            max_entries: 1000,
            entries: 500
          }
        }
      }
    end

    before do
      stub_const("SolidCache::Entry", Class.new)
      allow(SolidCache::Entry).to receive(:current_shard).and_return("shard1")
    end

    it "is a Check" do
      expect(subject).to be_a Check
    end

    context "#check" do
      let(:error_message) { "Error message" }

      context "with a successful connection" do
        before do
          expect(subject).to receive(:stats).and_return("test stats")
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "Cache is available (test stats)" }
      end

      context "with an unsuccessful connection" do
        before do
          expect(subject).to receive(:stats).and_raise(CacheCheckSolidCache::ConnectionFailed, error_message)
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "Error: '#{error_message}'" }
      end
    end

    context "#stats" do
      context "when can connect to cache" do
        before do
          allow(Rails).to receive_message_chain(:cache, :stats).and_return(stats)
        end

        it "returns a formatted stats string" do
          expect(subject.stats).to eq "entries: 500/1000, oldest: 30m, max: 1h, 2 connections"
        end
      end

      context "when no entries exist" do
        before do
          stats[:connection_stats]["shard1"][:oldest_age] = nil
          allow(Rails).to receive_message_chain(:cache, :stats).and_return(stats)
        end

        it "indicates no entries exist" do
          expect(subject.stats).to eq "entries: 500/1000, no entries, 2 connections"
        end
      end

      context "when cannot connect to cache" do
        before do
          allow(Rails).to receive_message_chain(:cache, :stats).and_raise("broken")
        end

        it { expect { subject.stats }.to raise_error(CacheCheckSolidCache::ConnectionFailed) }
      end

      context "when using a cache without stats" do
        before do
          allow(Rails.cache).to receive(:respond_to?).with(:stats).and_return(false)
        end

        it "returns an empty string" do
          expect(subject.stats).to eq ""
        end
      end
    end

    context "#format_duration" do
      it "formats seconds" do
        expect(subject.send(:format_duration, 45)).to eq "45s"
      end

      it "formats minutes" do
        expect(subject.send(:format_duration, 180)).to eq "3m"
      end

      it "formats hours" do
        expect(subject.send(:format_duration, 7200)).to eq "2h"
      end
    end
  end
end
