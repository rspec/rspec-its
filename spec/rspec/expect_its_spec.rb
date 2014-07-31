require 'spec_helper'

module RSpec
  describe ExpectIts do
    describe "#expect_its" do
      subject do
        Class.new do
          def value
            "new_value"
          end
        end.new
      end
      expect_its(:value) { to eq "new_value" }
      expect_its(:value) { not_to eq "old_value" }
      expect_its(:value) { to_not eq "old_value" }
    end
  end
end
