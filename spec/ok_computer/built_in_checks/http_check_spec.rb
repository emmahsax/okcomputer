require "rails_helper"

module OkComputer
  describe HttpCheck do
    let(:url) { "http://localurl:9000" }

    subject { described_class.new(url) }

    it "is a subclass of Check" do
      expect(subject).to be_a Check
    end

    describe "#new(url, request_timeout)" do
      it "requires url" do
        expect { described_class.new }.to raise_error(ArgumentError)
      end

      it "remembers url" do
        expect(subject.url).to eq(URI(url))
      end

      it "defaults request_timeout to 5 seconds" do
        expect(subject.request_timeout).to eq(5)
      end

      it "remembers request_timeout" do
        check = described_class.new(url, 10)
        expect(check.request_timeout).to eq(10)
      end

      it "coerces request_timeout to an integer" do
        check = described_class.new(url, "8")
        expect(check.request_timeout).to eq(8)
      end
    end

    describe "#check" do
      context "when the connection is successful" do
        before do
          allow(subject).to receive(:perform_request).and_return("foo")
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "HTTP check successful" }
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          allow(subject).to receive(:perform_request).and_raise(HttpCheck::ConnectionFailed, error_message)
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "Error: '#{error_message}'" }
      end
    end

    describe "#perform_request" do
      context "when the connection is successful" do
        before do
          allow(subject.url).to receive(:read).and_return("foo")
        end

        it "returns the response body" do
          expect(subject.perform_request).to eq("foo")
        end
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          allow(subject.url).to receive(:read).and_raise(Errno::ENETUNREACH)
        end

        it "raises a ConnectionFailed error" do
          expect { subject.perform_request }.to raise_error(HttpCheck::ConnectionFailed)
        end
      end

      context "when the connection takes too long" do
        before do
          subject.request_timeout = 0.1
          allow(subject.url).to receive(:read) { sleep(subject.request_timeout + 0.1) }
        end

        it "raises a ConnectionFailed error" do
          expect { subject.perform_request }.to raise_error(HttpCheck::ConnectionFailed)
        end
      end

      context "when basic authentication are set" do
        before do
          subject.parse_url('http://user:pass@foo.com')
          allow(subject.url).to receive(:read)
        end

        it "sets the Authorization header" do
          expect(subject.url).to receive(:read).with(
            { read_timeout: 5,
              http_basic_authentication: ['user', 'pass'] }
          )

          subject.perform_request
        end
      end

      context "when basic authentication credentials are not set" do
        before do
          allow(subject.url).to receive(:read)
        end

        it "does not set the Authorization header" do
          expect(subject.url).to receive(:read).with({ read_timeout: 5 })

          subject.perform_request
        end
      end
    end

    describe '#parse_url' do
      subject { described_class.new('') }

      it 'assigns the url attribute as expected' do
        subject.parse_url('http://foo.com')
        expect(subject.url.to_s).to eq('http://foo.com')
      end

      it 'extracts and assigns the username and password' do
        subject.parse_url('http://user:pass@foo.com')
        expect(subject.url.to_s).to eq('http://foo.com')
        expect(subject.basic_auth_username).to eq('user')
        expect(subject.basic_auth_password).to eq('pass')
      end

      it 'sets userinfo to nil when parsing a url with user/pass' do
        subject.parse_url('http://user:pass@foo.com')
        expect(subject.url.userinfo).to be nil
      end
    end

    describe '#basic_auth_options' do
      subject { described_class.new('') }

      it 'returns an array with the parsed username and password from the url' do
        subject.parse_url('http://user:pass@foo.com')
        expect(subject.basic_auth_options).to eq(['user','pass'])
      end
    end
  end
end
