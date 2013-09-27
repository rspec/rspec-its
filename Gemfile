source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-its.gemspec
gemspec

USE_LOCAL_RSPEC_GEMS = false

%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && USE_LOCAL_RSPEC_GEMS
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
  end
end

gem 'simplecov'
gem 'coveralls'
gem 'aruba'
gem 'cucumber'
