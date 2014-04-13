require 'rspec/its/version'
require 'rspec/core'

module RSpec
  module Its

    # Creates a nested example group named by the submitted `attribute`,
    # and then generates an example using the submitted block.
    #
    # @example
    #
    #   # This ...
    #   describe Array do
    #     its(:size) { should eq(0) }
    #   end
    #
    #   # ... generates the same runtime structure as this:
    #   describe Array do
    #     describe "size" do
    #       it "should eq(0)" do
    #         subject.size.should eq(0)
    #       end
    #     end
    #   end
    #
    # The attribute can be a `Symbol` or a `String`. Given a `String`
    # with dots, the result is as though you concatenated that `String`
    # onto the subject in an expression.
    #
    # @example
    #
    #   describe Person do
    #     subject do
    #       Person.new.tap do |person|
    #         person.phone_numbers << "555-1212"
    #       end
    #     end
    #
    #     its("phone_numbers.first") { should eq("555-1212") }
    #   end
    #
    # When the subject is a `Hash`, you can refer to the Hash keys by
    # specifying a `Symbol` or `String` in an array.
    #
    # @example
    #
    #   describe "a configuration Hash" do
    #     subject do
    #       { :max_users => 3,
    #         'admin' => :all_permissions }
    #     end
    #
    #     its([:max_users]) { should eq(3) }
    #     its(['admin']) { should eq(:all_permissions) }
    #
    #     # You can still access to its regular methods this way:
    #     its(:keys) { should include(:max_users) }
    #     its(:count) { should eq(2) }
    #   end
    #
    # With an implicit subject, `is_expected` can be used as an alternative
    # to `should` (e.g. for one-liner use)
    #
    # @example
    #
    #   describe Array do
    #     its(:size) { is_expected.to eq(0) }
    #   end
    #
    # Note that this method does not modify `subject` in any way, so if you
    # refer to `subject` in `let` or `before` blocks, you're still
    # referring to the outer subject.
    #
    # @example
    #
    #   describe Person do
    #     subject { Person.new }
    #     before { subject.age = 25 }
    #     its(:age) { should eq(25) }
    #   end
    def its(attribute, &block)
      describe(attribute.to_s) do
        if Array === attribute
          let(:__its_subject) { subject[*attribute] }
        else
          let(:__its_subject) do
            attribute_chain = attribute.to_s.split('.')
            attribute_chain.inject(subject) do |inner_subject, attr|
              inner_subject.send(attr)
            end
          end
        end

        def is_expected
          expect(__its_subject)
        end

        def should(matcher=nil, message=nil)
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(__its_subject, matcher, message)
        end

        def should_not(matcher=nil, message=nil)
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(__its_subject, matcher, message)
        end

        its_caller = caller.select {|file_line| file_line !~ %r(/lib/rspec/its) }
        example(nil, :caller => its_caller, &block)

      end
    end

  end
end

RSpec.configure do |rspec|
  rspec.extend RSpec::Its
  rspec.backtrace_exclusion_patterns << %r(/lib/rspec/its)
end

RSpec::SharedContext.send(:include, RSpec::Its)
