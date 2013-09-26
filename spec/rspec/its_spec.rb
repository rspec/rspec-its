require 'spec_helper'

module RSpec::Core
  describe MemoizedHelpers do
    before(:each) { RSpec.configuration.configure_expectation_framework }

    describe "#its" do
      subject do
        Class.new do
          def initialize
            @call_count = 0
          end

          def call_count
            @call_count += 1
          end
        end.new
      end

      context "with a call counter" do
        its(:call_count) { should eq(1) }
      end

      context "with nil value" do
        subject do
          Class.new do
            def nil_value
              nil
            end
          end.new
        end
        its(:nil_value) { should be_nil }
      end

      context "with nested attributes" do
        subject do
          Class.new do
            def name
              "John"
            end
          end.new
        end
        its("name")            { should eq("John") }
        its("name.size")       { should eq(4) }
        its("name.size.class") { should eq(Fixnum) }
      end

      context "when it responds to #[]" do
        subject do
          Class.new do
            def [](*objects)
              objects.map do |object|
                "#{object.class}: #{object.to_s}"
              end.join("; ")
            end

            def name
              "George"
            end
          end.new
        end
        its([:a]) { should eq("Symbol: a") }
        its(['a']) { should eq("String: a") }
        its([:b, 'c', 4]) { should eq("Symbol: b; String: c; Fixnum: 4") }
        its(:name) { should eq("George") }
        context "when referring to an attribute without the proper array syntax" do
          context "it raises an error" do
            its(:age) do
              expect do
                should eq(64)
              end.to raise_error(NoMethodError)
            end
          end
        end
      end

      context "when it does not respond to #[]" do
        subject { Object.new }

        context "it raises an error" do
          its([:a]) do
            expect do
              should eq("Symbol: a")
            end.to raise_error(NoMethodError)
          end
        end
      end

      context "calling and overriding super" do
        it "calls to the subject defined in the parent group" do
          group = ExampleGroup.describe(Array) do
            subject { [1, 'a'] }

            its(:last) { should eq("a") }

            describe '.first' do
              def subject; super().first; end

              its(:next) { should eq(2) }
            end
          end

          expect(group.run(NullObject.new)).to be_truthy
        end
      end

      context "with nil subject" do
        subject do
          Class.new do
            def initialize
              @counter = -1
            end
            def nil_if_first_time
              @counter += 1
              @counter == 0 ? nil : true
            end
          end.new
        end
        its(:nil_if_first_time) { should be(nil) }
      end

      context "with false subject" do
        subject do
          Class.new do
            def initialize
              @counter = -1
            end
            def false_if_first_time
              @counter += 1
              @counter > 0
            end
          end.new
        end
        its(:false_if_first_time) { should be(false) }
      end

      describe 'accessing `subject` in `before` and `let`' do
        subject { 'my subject' }
        before { @subject_in_before = subject }
        let(:subject_in_let) { subject }
        let!(:eager_loaded_subject_in_let) { subject }

        # These examples read weird, because we're actually
        # specifying the behaviour of `its` itself
        its(nil) { expect(subject).to eq('my subject') }
        its(nil) { expect(@subject_in_before).to eq('my subject') }
        its(nil) { expect(subject_in_let).to eq('my subject') }
        its(nil) { expect(eager_loaded_subject_in_let).to eq('my subject') }
      end
    end
  end
end
