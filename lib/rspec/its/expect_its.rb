require 'rspec/its/version'
require 'rspec/core'

module RSpec
  module ExpectIts
    # @example
    #
    #   # Write this ...
    #   describe Array do
    #     expect_its(:size) { to eq(0) }
    #   end
    #
    #   # instead of ...
    #   describe Array do
    #     its(:size) { is_expected.to eq(0) }
    #   end

    def expect_its(attribute, &block)
      describe(attribute.to_s) do
        if Array === attribute
          let(:__its_expect) { expect subject[*attribute] }
        else
          let(:__its_expect) do
            attribute_chain = attribute.to_s.split('.')
            expect(attribute_chain.inject(subject) do |inner_subject, attr|
              inner_subject.send(attr)
            end)
          end
        end

        def method_missing(method, *args)
          __its_expect.send(method, *args)
        end

        expect_its_caller = caller.select {|file_line| file_line !~ %r(/lib/rspec/its) }
        example(nil, :caller => expect_its_caller, &block)
      end
    end
  end
end

RSpec.configure do |rspec|
  rspec.extend RSpec::ExpectIts
  rspec.backtrace_exclusion_patterns << %r(/lib/rspec/its)
end

RSpec::SharedContext.send(:include, RSpec::ExpectIts)
