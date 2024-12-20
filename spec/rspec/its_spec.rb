# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Its do
  context "with implicit subject" do
    context "preserves described_class" do
      its(:symbol) { expect(described_class).to be RSpec::Its }
      its([]) { expect(described_class).to be RSpec::Its }
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
      its(:call_count, :meta) { is_expected.to eq(2) }
    end

    context "with a call counter" do
      its(:call_count) { is_expected.to eq(1) }
    end

    context "with nil value" do
      subject do
        Class.new do
          def nil_value
            nil
          end
        end.new
      end

      its(:nil_value) { is_expected.to be_nil }
    end

    context "with nested attributes" do
      subject do
        Class.new do
          def name
            "John"
          end
        end.new
      end

      its("name") { is_expected.to eq("John") }
      its("name.size") { is_expected.to eq(4) }
      its("name.size.class") { is_expected.to eq(Integer) }

      context "using are_expected" do
        its("name.chars.to_a") { are_expected.to eq(%w[J o h n]) }
      end

      context "using will_not" do
        its("name") { will_not raise_error }
      end

      context "using should" do
        its("name") { should eq("John") }
      end

      context "using should_not" do
        its("name") { should_not eq("Paul") }
      end
    end

    context "when it responds to #[]" do
      subject do
        Class.new do
          def [](*objects)
            objects.map do |object|
              "#{object.class}: #{object}"
            end.join("; ")
          end

          def name
            "George"
          end
        end.new
      end

      its([:a]) { is_expected.to eq("Symbol: a") }
      its(['a']) { is_expected.to eq("String: a") }
      its([:b, 'c', 4]) { is_expected.to eq("Symbol: b; String: c; Integer: 4") }
      its(:name) { is_expected.to eq("George") }

      context "when referring to an attribute that doesn't exist" do
        context "it raises an error" do
          its(:age) do
            expect do
              is_expected.to eq(64)
            end.to raise_error(NoMethodError)
          end

          context "using will" do
            its(:age) { will raise_error(NoMethodError) }
          end
        end
      end

      context "when it's a hash" do
        subject { { a: { deep: { key: "value" } } } }

        its([:a]) { is_expected.to eq({ deep: { key: "value" } }) }
        its(%i[a deep]) { is_expected.to eq({ key: "value" }) }
        its(%i[a deep key]) { is_expected.to eq("value") }

        context "when referring to a key that doesn't exist" do
          its([:not_here]) { is_expected.to be_nil }
          its(%i[a ghost]) { are_expected.to be_nil }
          its(%i[deep ghost]) { expect { is_expected.to eq("missing") }.to raise_error(NoMethodError) }

          context "using will" do
            its(%i[deep ghost]) { will raise_error(NoMethodError) }
          end
        end
      end
    end

    context "when it does not respond to #[]" do
      subject { Object.new }

      context "it raises an error" do
        its([:a]) do
          expect { is_expected.to eq("Symbol: a") }.to raise_error(NoMethodError)
        end

        context "using will" do
          its([:a]) { will raise_error(NoMethodError) }
        end
      end
    end

    context "calling and overriding super" do
      it "calls to the subject defined in the parent group" do
        group = RSpec::Core::ExampleGroup.describe(Array) do
          subject { [1, 'a'] }

          its(:last) { is_expected.to eq("a") }

          describe '.first' do
            def subject
              super.first
            end

            its(:next) { is_expected.to eq(2) }
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

      its(:nil_if_first_time) { is_expected.to be(nil) }
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

      its(:false_if_first_time) { is_expected.to be(false) }
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

        its(:name) { is_expected.to eq "Array" }
      end

      include_context "shared stuff"
    end

    describe "when extending SharedContext" do
      it 'works with an implicit subject' do
        shared = Module.new do
          extend RSpec::SharedContext
          its(:size) { is_expected.to eq 0 }
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
      its([], :foo, bar: 17) do |example|
        expect(example.metadata[:foo]).to be(true)
        expect(example.metadata[:bar]).to be(17)
      end
    end
  end

  context "when expecting errors" do
    subject do
      Class.new do
        def good; end

        def bad
          raise ArgumentError, "message"
        end
      end.new
    end

    its(:good) { will_not raise_error }
    its(:bad) { will raise_error(ArgumentError) }
    its(:bad) { will raise_error("message") }
    its(:bad) { will raise_error(ArgumentError, "message") }
  end

  context "when expecting throws" do
    subject do
      Class.new do
        def good; end

        def bad
          throw :abort, "message"
        end
      end.new
    end

    its(:good) { will_not throw_symbol }
    its(:bad) { will throw_symbol }
    its(:bad) { will throw_symbol(:abort) }
    its(:bad) { will throw_symbol(:abort, "message") }
  end

  context "with change observation" do
    subject do
      Class.new do
        attr_reader :count

        def initialize
          @count = 0
        end

        def increment
          @count += 1
        end

        def noop; end
      end.new
    end

    its(:increment) { will change { subject.count }.by(1) }
    its(:increment) { will change { subject.count }.from(0) }
    its(:increment) { will change { subject.count }.from(0).to(1) }
    its(:increment) { will change { subject.count }.by_at_least(1) }
    its(:increment) { will change { subject.count }.by_at_most(1) }

    its(:noop) { will_not(change { subject.count }) }
    its(:noop) { will_not change { subject.count }.from(0) }

    its(:increment) do
      expect { will_not change { subject.count }.by(0) }.to \
        raise_error(NotImplementedError, '`expect { }.not_to change { }.by()` is not supported')
    end

    its(:increment) do
      expect { will_not change { subject.count }.by_at_least(2) }.to \
        raise_error(NotImplementedError, '`expect { }.not_to change { }.by_at_least()` is not supported')
    end

    its(:increment) do
      expect { will_not change { subject.count }.by_at_most(3) }.to \
        raise_error(NotImplementedError, '`expect { }.not_to change { }.by_at_most()` is not supported')
    end
  end

  context "with output capture" do
    subject do
      Class.new do
        def stdout
          print "some output"
        end

        def stderr
          $stderr.print "some error"
        end

        def noop; end
      end.new
    end

    its(:stdout) { will output("some output").to_stdout }
    its(:stderr) { will output("some error").to_stderr }

    its(:noop) { will_not output("some error").to_stderr }
    its(:noop) { will_not output("some output").to_stdout }
  end

  context "#will with non block expectations" do
    subject do
      Class.new do
        def terminator
          "back"
        end
      end.new
    end

    its(:terminator) do
      expect { will be("back") }.to \
        raise_error(ArgumentError, '`will` only supports block expectations')
    end

    its(:terminator) do
      expect { will_not be("back") }.to \
        raise_error(ArgumentError, '`will_not` only supports block expectations')
    end
  end

  context "when example is redefined" do
    subject do
      Class.new do
        def will_still_work
          true
        end
      end.new
    end

    def self.example(*_args)
      raise
    end

    its(:will_still_work) { is_expected.to be true }
  end

  context "with private method" do
    subject(:klass) do
      Class.new do
        def name
          private_name
        end

        private

        def private_name
          "John"
        end
      end.new
    end

    context "when referring indirectly" do
      its(:name) { is_expected.to eq "John" }
    end

    context "when attempting to refer directly" do
      context "it raises an error" do
        its(:private_name) do
          expect { is_expected.to eq("John") }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
