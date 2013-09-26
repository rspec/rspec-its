source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-its.gemspec
gemspec

%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => "2-99-maintenance"
  end
end

gem 'simplecov'
gem 'coveralls'
gem 'aruba'
gem 'cucumber'
