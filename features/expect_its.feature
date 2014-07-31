Feature: expecting attribute of subject

  Scenario: specify value of an attribute of a hash
    Given a file named "example_spec.rb" with:
    """ruby
      describe Hash do
        context "with two items" do
          subject do
            {:one => 'one', :two => 'two'}
          end

          expect_its(:size) { to eq(2) }
        end
      end
      """
    When I run rspec
    Then the examples should all pass

  Scenario: failures are correctly reported as coming from the `expect_its` line
    Given a file named "example_spec.rb" with:
    """ruby
      describe Array do
        context "when first created" do
          expect_its(:size) { not_to eq(0) }
        end
      end
      """
    When I run rspec
    Then the output should contain "Failure/Error: expect_its(:size) { not_to eq(0) }"
    And the output should not match /#[^\n]*rspec[\x2f]its/
