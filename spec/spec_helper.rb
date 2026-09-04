# frozen_string_literal: true

require 'rspec/its'

Dir['./spec/support/**/*'].each { |f| require f }

class NullFormatter
  private

  def method_missing(method, *args, &block)
    # ignore
  end

  def respond_to_missing?(method, *args, &block)
    # ignore
  end
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true if config.respond_to?(:run_all_when_everything_filtered)
  config.order = 'random'
end
