# RSpec::Its [![Build Status](https://travis-ci.org/rspec/rspec-its.png)](https://travis-ci.org/rspec/rspec-its)

RSpec::Its provides the `its` method as a short-hand to specify the expected value of an attribute.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-its'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-its

## Usage

Use the `its` method to generate a nested example group with
a single example that specifies the expected value of an attribute of the
subject using `should`, `should_not` or `is_expected`.

`its` accepts a symbol or a string, and a block representing the example.

    its(:size)    { should eq(1) }
    its("length") { should eq(1) }

You can use a string with dots to specify a nested attribute (i.e. an
attribute of the attribute of the subject).

    its("phone_numbers.size") { should_not eq(0) }

When the subject is a hash, you can pass in an array with a single key to
access the value at that key in the hash.

    its([:key]) { is_expected.to eq(value) }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
