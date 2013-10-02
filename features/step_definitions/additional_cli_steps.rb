When /^I run rspec( with the documentation option)?$/ do |documentation|
  rspec_its_gem_location = File.expand_path('../../../lib/rspec/its', __FILE__)
  require_option = "--require #{rspec_its_gem_location}"
  format_option = documentation ? "--format documentation" : ""
  rspec_command = ['rspec', require_option, format_option, 'example_spec.rb'].join(' ')
  step "I run `#{rspec_command}`"
end

Then /^the example(?:s)? should(?: all)? pass$/ do
  step %q{the output should contain "0 failures"}
  step %q{the output should not contain "0 examples"}
  step %q{the exit status should be 0}
end
