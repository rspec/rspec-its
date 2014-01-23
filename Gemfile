source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-its.gemspec
gemspec

%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git",
             :branch => ENV.fetch('BRANCH','master')
  end
end

# only pull rspec-support from master

gem "rspec-support", :git => "git://github.com/rspec/rspec-support.git"

# test coverage
# gem 'simplecov', :require => false

gem 'coveralls', :require => false, :platform => :mri_20

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')

platform :rbx do
  gem 'rubysl'
end