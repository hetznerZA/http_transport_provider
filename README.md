# HttpTransportProvider [![Build Status](https://travis-ci.org/hetznerZA/http_transport_provider.svg?branch=master)](https://travis-ci.org/hetznerZA/http_transport_provider)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_transport_provider'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_transport_provider

## Usage
The provider currently only supports GET & POST. In these examples _'my_identifier'_ is the name you are giving your instance.

GET:
```ruby
htp = HttpTransportProvider.new('my_identifier')
htp.configure({'verb' => "GET"})
htp.send_message('http://localhost:3000', 'body' => {'id' => 1})
htp.receive_message
```

GET with parameters:
```ruby
htp = HttpTransportProvider.new('my_identifier')
htp.configure({'verb' => "GET"})
htp.send_message('http://localhost:3000', 'body' => {})
htp.receive_message
```

POST:
```ruby
htp = HttpTransportProvider.new('my_identifier')
htp.configure({'verb' => "POST"})
htp.send_message('http://localhost:3000', 'body' => {'id' => 1})
htp.receive_message
```

Basic Auth:
```ruby
htp = HttpTransportProvider.new('my_identifier')
htp.configure({'verb' => 'POST', 'credentials' => {'username' => 'user', 'password' => 'secret'}})
htp.send_message('http://localhost:3000', 'body' => {'id' => 1})
htp.receive_message
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/http_transport_provider.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
