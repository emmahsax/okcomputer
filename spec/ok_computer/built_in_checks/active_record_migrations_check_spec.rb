require "rails_helper"

module OkComputer
  describe ActiveRecordMigrationsCheck do
    it "is a subclass of Check" do
      expect(subject).to be_a Check
    end

    current_rails_version = Gem::Version.new(ActiveRecord::VERSION::STRING)

    # 4.0 <= Rails < 7.2
    if current_rails_version > Gem::Version.new("3.99.99") && current_rails_version < Gem::Version.new("7.2")
      context "when activerecord supports needs_migration?" do
        context "#supported?" do
          it { expect(subject.supported?).to be_truthy }
        end

        context "#check" do
          context "with no pending migrations" do
            before do
              expect(subject).to receive(:needs_migration?).and_return(false)
            end

            it { is_expected.to be_successful_check }
            it { is_expected.to have_message "NO pending migrations" }
          end

          context "with pending migrations" do
            before do
              expect(subject).to receive(:needs_migration?).and_return(true)
            end

            it { is_expected.not_to be_successful_check }
            it { is_expected.to have_message "Pending migrations" }
          end
        end
      end
    else # Rails <= 3.2
      context "when on older versions of ActiveRecord" do
        context "#supported?" do
          it { expect(subject.supported?).to be_falsey }
        end

        context "#check" do
          it { is_expected.not_to be_successful_check }
          it { is_expected.to have_message "This version of ActiveRecord does not support checking whether migrations are pending" }
        end
      end
    end
  end
end
