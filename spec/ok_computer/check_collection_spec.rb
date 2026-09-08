require "rails_helper"

module OkComputer
  describe CheckCollection do
    let(:foocheck) { Check.new }
    let(:barcheck) { Check.new }
    let(:registry) { {foo: foocheck, bar: barcheck} }

    subject { CheckCollection.new("foo collection name") }
    let(:default_collection) { CheckCollection.new("foo collection name", true) }

    context ".new" do
      it "sets the display name of the check collection" do
        subject.register(:foo, foocheck)
        subject.register(:bar, barcheck)
        expect(subject.display).to eq("foo collection name")
      end
    end

    [false, true].each do |check_in_parallel|
      before { OkComputer.check_in_parallel = check_in_parallel }

      context "with check_in_parallel set to #{check_in_parallel}" do
        context "#run" do
          it "runs its registered checks" do
            subject.register(:foo, foocheck)
            subject.register(:bar, barcheck)
            expect(foocheck).to receive(:run)
            expect(barcheck).to receive(:run)
            subject.run
          end

          it "does not run checks registered with skip_all" do
            foocheck.skip_all = true
            default_collection.register(:foo, foocheck)
            default_collection.register(:bar, barcheck)
            expect(foocheck).not_to receive(:run)
            expect(barcheck).to receive(:run)
            default_collection.run
          end
        end
      end
    end

    context "#checks" do
      it "returns the checks from its registry" do
        subject.register(:foo, foocheck)
        subject.register(:bar, barcheck)
        expect(subject.checks).to eq(registry.values)
      end

      it "omits checks registered with skip_all" do
        foocheck.skip_all = true
        default_collection.register(:foo, foocheck)
        default_collection.register(:bar, barcheck)
        expect(default_collection.checks).to eq([barcheck])
      end

      it "does not omit skipped checks from a named collection" do
        foocheck.skip_all = true
        subject.register(:foo, foocheck)
        expect(subject.checks).to eq([foocheck])
      end
    end

    context "#register" do
      it "registers a check" do
        subject.register(:foo, foocheck)
        expect(subject.checks).to include(foocheck)
      end
    end

    context "#deregister" do
      it "deregisters a check" do
        subject.register(:foo, foocheck)
        expect(subject.checks).to include(foocheck)
        subject.deregister(:foo)
        expect(subject.checks).not_to include(foocheck)
      end
    end

    context "#fetch" do
      it "finds checks in the current collection" do
        subject.register(:foo, foocheck)
        expect(subject.fetch(:foo)).to eq(foocheck)
      end

      it "finds checks registered with skip_all" do
        foocheck.skip_all = true
        subject.register(:foo, foocheck)
        expect(subject.fetch(:foo)).to eq(foocheck)
      end

      it "finds checks in a sub_collection" do
        sub_collection = CheckCollection.new("sub")
        subject.register("sub", sub_collection)
        sub_collection.register("foo_subcheck", foocheck)
        expect(subject.fetch("foo_subcheck")).to eq(foocheck)
      end

      it "finds checks in a sub_collection's sub_collection" do
        sub_collection = CheckCollection.new("sub")
        subject.register("sub", sub_collection)
        sub_sub_collection = CheckCollection.new("sub_sub")
        sub_collection.register("sub_sub", sub_sub_collection)
        sub_sub_collection.register("foo_subcheck", foocheck)
        expect(subject.fetch("foo_subcheck")).to eq(foocheck)
      end

      it "raises a  KeyError if the check is not in the collection or a sub_collection" do
        sub_collection = CheckCollection.new("sub")
        subject.register("sub", sub_collection)
        sub_collection.register("foo_subcheck", foocheck)
        expect{ subject.fetch("bar_subcheck") }.to raise_error(KeyError)
      end


      it "finds the check in a sub_collection when the sub_collection is not the first sub_collection" do
        sub_collection_1 = CheckCollection.new("sub1")
        sub_collection_2 = CheckCollection.new("sub2")
        subject.register("sub1", sub_collection_1)
        subject.register("sub2", sub_collection_2)
        sub_collection_2.register("foo_subcheck", foocheck)
        expect(subject.fetch("foo_subcheck")).to eq(foocheck)
      end
    end

    context "#[]" do
      it "returns nil if the if the check is not in the collection or a sub_collection" do
        sub_collection = CheckCollection.new("sub")
        subject.register("sub", sub_collection)
        sub_collection.register("foo_subcheck", foocheck)
        expect(subject["bar_subcheck"]).to eq(nil)
      end
    end

    context "#to_text" do
      let(:foocheck) { Check.new }
      let(:barcheck) { Check.new }

      subject { CheckCollection.new("foo collection name") }

      it "returns the #to_text of each check on a new line" do
        subject.register(:foo, foocheck)
        subject.register(:bar, barcheck)
        allow(foocheck).to receive(:to_text) { "foo" }
        allow(barcheck).to receive(:to_text) { "bar" }
        expect(subject.to_text).to eq("foo collection name\n\s\sbar\n\s\sfoo")
      end

      it "omits checks registered with skip_all" do
        foocheck.skip_all = true
        default_collection.register(:foo, foocheck)
        default_collection.register(:bar, barcheck)
        allow(foocheck).to receive(:to_text) { "foo" }
        allow(barcheck).to receive(:to_text) { "bar" }
        expect(foocheck).not_to receive(:to_text)
        expect(default_collection.to_text).to eq("foo collection name\n\s\sbar")
      end
    end

    context "#to_json" do
      it "returns the #to_json of each check in a JSON array" do
        subject.register(:foo, foocheck)
        subject.register(:bar, barcheck)
        allow(foocheck).to receive(:to_json) { {"foo" => "foo result"}.to_json }
        allow(barcheck).to receive(:to_json) { {"bar" => "bar result"}.to_json }
        combined_hash = JSON.parse(foocheck.to_json).merge(JSON.parse(barcheck.to_json))
        expect(subject.to_json).to eq(combined_hash.to_json)
      end

      it "omits checks registered with skip_all" do
        foocheck.skip_all = true
        default_collection.register(:foo, foocheck)
        default_collection.register(:bar, barcheck)
        allow(foocheck).to receive(:to_json) { {"foo" => "foo result"}.to_json }
        allow(barcheck).to receive(:to_json) { {"bar" => "bar result"}.to_json }
        expect(foocheck).not_to receive(:to_json)
        expect(default_collection.to_json).to eq({"bar" => "bar result"}.to_json)
      end
    end

    context "#success?" do
      it "is true if all checks are true" do
        subject.register(:foo, foocheck)
        subject.register(:bar, barcheck)
        allow(foocheck).to receive(:success?) { true }
        allow(barcheck).to receive(:success?) { true }
        expect(subject).to be_success
      end

      it "is failse if any check is false" do
        subject.register(:foo, foocheck)
        subject.register(:bar, barcheck)
        allow(foocheck).to receive(:success?) { true }
        allow(barcheck).to receive(:success?) { false }
        expect(subject).not_to be_success
      end

      it "ignores failures from checks registered with skip_all" do
        foocheck.skip_all = true
        default_collection.register(:foo, foocheck)
        default_collection.register(:bar, barcheck)
        allow(barcheck).to receive(:success?) { true }
        expect(foocheck).not_to receive(:success?)
        expect(default_collection).to be_success
      end
    end
  end
end
