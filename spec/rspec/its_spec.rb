require 'spec_helper'

module RSpec
  describe Its do
    describe "#its" do
      context "with implicit subject" do
        context "preserves described_class" do
          its(:symbol) { expect(described_class).to be Its }
          its([]) { expect(described_class).to be Its }
        end
      end
      context "with explicit subject" do
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

        before(:each, :meta) do
          subject.call_count
        end

        context "with some metadata" do
          its(:call_count, :meta) { should eq(2) }
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
          its("name") { should eq("John") }
          its("name.size") { should eq(4) }
          its("name.size.class") { should eq(Fixnum) }

          context "using should_not" do
            its("name") { should_not eq("Paul") }
          end

          context "using is_expected" do
            its("name") { is_expected.to eq("John") }
          end

          context "using are_expected" do
            its("name.chars.to_a") { are_expected.to eq(%w[J o h n]) }
          end
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
          context "when referring to an attribute that doesn't exist" do
            context "it raises an error" do
              its(:age) do
                expect do
                  should eq(64)
                end.to raise_error(NoMethodError)
              end
            end
          end

          context "when it's a hash" do
            subject { {:a => {:deep => {:key => "value"}}} }

            its([:a]) { should eq({:deep => {:key => "value"}}) }
            its([:a, :deep]) { should eq({:key => "value"}) }
            its([:a, :deep, :key]) { should eq("value") }

            context "when referring to a key that doesn't exist" do
              its([:not_here]) { should be_nil }
              its([:a, :ghost]) { should be_nil }
              its([:deep, :ghost]) { expect { should eq("missing") }.to raise_error(NoMethodError) }
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
            group = RSpec::Core::ExampleGroup.describe(Array) do
              subject { [1, 'a'] }

              its(:last) { should eq("a") }

              describe '.first' do
                def subject;
                  super().first;
                end

                its(:next) { should eq(2) }
              end
            end

            expect(group.run(NullFormatter.new)).to be_truthy
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

        describe "in shared_context" do
          shared_context "shared stuff" do
            subject { Array }
            its(:name) { should eq "Array" }
          end

          include_context "shared stuff"
        end

        describe "when extending SharedContext" do
          it 'works with an implicit subject' do
            shared = Module.new do
              extend RSpec::SharedContext
              its(:size) { should eq 0 }
            end
            group = RSpec::Core::ExampleGroup.describe(Array) do
              include shared
            end

            group.run(NullFormatter.new)

            result = group.children.first.examples.first.execution_result
            # Following conditional needed to work across mix of RSpec and ruby versions without warning
            status = result.respond_to?(:status) ? result.status : result[:status].to_sym
            expect(status).to eq(:passed)
          end
        end
      end
      context "with metadata" do
        context "preserves access to metadata that doesn't end in hash" do
          its([], :foo) do |example|
            expect(example.metadata[:foo]).to be(true)
          end
        end
        context "preserves access to metadata that ends in hash" do
          its([], :foo, :bar => 17) do |example|
            expect(example.metadata[:foo]).to be(true)
            expect(example.metadata[:bar]).to be(17)
          end
        end
      end
    end
  end
end
