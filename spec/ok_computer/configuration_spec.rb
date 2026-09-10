require "rails_helper"

describe OkComputer do
  let(:username) { "foo" }
  let(:password) { "bar" }
  let(:whitelist) { [:default] }
  let(:bogus) { "asdfasdfasdfas" }

  context "#require_authentication" do
    it "captures username and password necessary to access OkComputer" do
      OkComputer.require_authentication(username, password)
      expect(OkComputer.send(:username)).to eq(username)
      expect(OkComputer.send(:password)).to eq(password)
      expect(OkComputer.send(:whitelist)).to be_empty
    end

    it "captures an optional list of whitelisted actions to skip authentication" do
      OkComputer.require_authentication(username, password, except: whitelist)
      expect(OkComputer.send(:whitelist)).to eq(whitelist)
    end
  end

  context "#requires_authentication?" do
    context "with a configured username and password" do
      before do
        OkComputer.send(:username=, username)
        OkComputer.send(:password=, password)
      end

      context "without a whitelist" do
        before do
          allow(OkComputer).to receive(:options) { {} }
        end

        it "is true" do
          expect(OkComputer.requires_authentication?).to be_truthy
        end
      end

      context "with a whitelist" do
        let(:action) { "default" }
        before do
          OkComputer.send(:options=, {except: [action]})
        end

        it "is true for the #index action" do
          expect(OkComputer.requires_authentication?({action: "index"})).to be_truthy
        end

        it "is true for #show if params[:check] is not whitelisted" do
          expect(OkComputer.requires_authentication?({action: "show", check: "somethingelse"})).to be_truthy
        end

        it "is false for #show if params[:check] is whitelisted" do
          expect(OkComputer.requires_authentication?({action: "show", check: action})).not_to be_truthy
        end
      end
    end

    context "without a configured username and password" do
      before do
        OkComputer.send(:username=, nil)
        OkComputer.send(:password=, nil)
        OkComputer.send(:options=, {})
      end

      it "is false" do
        expect(OkComputer.requires_authentication?).to be_falsey
      end
    end
  end

  context "#authenticate(username, password)" do
    it "returns true if OkComputer is not set up to require authentication" do
      OkComputer.require_authentication(nil, nil)
      expect(OkComputer.authenticate(bogus, bogus)).to be_truthy
    end

    context "when set up to require authentication" do
      before do
        OkComputer.require_authentication(username, password)
      end

      it "returns true if given the correct username and password" do
        expect(OkComputer.authenticate(username, password)).to be_truthy
      end

      it "returns false if not given the correct username and password" do
        expect(OkComputer.authenticate(bogus, bogus)).to be_falsey
      end
    end
  end

  context "#mount_at" do
    it "has default mount_at value of 'okcomputer'" do
      expect(OkComputer.mount_at).to eq('okcomputer')
    end

    it "allows configuration of mount_at" do
      expect(OkComputer.respond_to?('mount_at=')).to be_truthy
    end
  end

  context "#analytics_ignore" do
    it "has default mount_at value of true" do
      expect(OkComputer.analytics_ignore).to eq(true)
    end

    it "allows configuration of analytics_ignore" do
      expect(OkComputer.respond_to?('analytics_ignore=')).to be_truthy
    end
  end

  context "#logger" do
    it "has a default logger value of a nil logger" do
      expect(OkComputer.logger).to be_a Logger
    end

    it "allows configuration of logger" do
      expect(OkComputer.respond_to?('logger=')).to be_truthy
    end
  end

  context '#make_optional' do
    before do
      OkComputer::Registry.register "some_required_check", OkComputer::RubyVersionCheck.new
      OkComputer::Registry.register "some_optional_check", OkComputer::RubyVersionCheck.new
    end

    around(:each) do |example|
      with_clean_registry { example.run }
    end

    it "marks listed checks as optional" do
      OkComputer.make_optional %w(some_optional_check)
      expect(OkComputer::Registry.fetch("some_required_check")).not_to be_a_kind_of OkComputer::OptionalCheck
      expect(OkComputer::Registry.fetch("some_optional_check")).to be_a_kind_of OkComputer::OptionalCheck
    end
  end
end
