# Ignite Ruby

:fire: Ruby client for [Apache Ignite](https://ignite.apache.org/)

[![Build Status](https://github.com/ankane/ignite-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/ankane/ignite-ruby/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "ignite-client"
```

## Getting Started

Create a client

```ruby
client = Ignite::Client.new
```

See [connection options](#connection-options) for more info

## Key-Value API

Create a cache

```ruby
cache = client.get_or_create_cache("test")
```

Add data

```ruby
cache.put("hello", "world")
cache.get("hello")
```

Supports these methods

```ruby
cache.get(key)
cache.get_all(keys)
cache.put(key, value)
cache.put_all(objects)
cache.key?(key)
cache.keys?(keys)
cache.get_and_put(key, value)
cache.get_and_replace(key, value)
cache.get_and_remove(key)
cache.put_if_absent(key, value)
cache.get_and_put_if_absent(key, value)
cache.replace(key, value)
cache.replace_if_equals(key, compare, value)
cache.clear
cache.clear_key(key)
cache.clear_keys(keys)
cache.remove_key(key)
cache.remove_if_equals(key, compare)
cache.size
cache.remove_keys(keys)
cache.remove_all
```

## Scan Queries

Scan objects

```ruby
cache.scan do |k, v|
  # ...
end
```

## SQL

Execute SQL queries

```ruby
client.query("SELECT * FROM users")
```

Pass arguments

```ruby
client.query("SELECT * FROM products WHERE name = ?", ["Ignite"])
```

## Connection Options

Specify the host and port

```ruby
Ignite::Client.new(host: "localhost", port: 10800)
```

Specify the connect timeout

```ruby
Ignite::Client.new(connect_timeout: 3)
```

## Authentication

For [authentication](https://ignite.apache.org/docs/latest/security/authentication), use:

```ruby
Ignite::Client.new(username: "ignite", password: "ignite")
```

SSL is automatically enabled when credentials are supplied. To disable, use:

```ruby
Ignite::Client.new(username: "ignite", password: "ignite", use_ssl: false)
```

## SSL/TLS

For [SSL/TLS](https://ignite.apache.org/docs/latest/security/ssl-tls#ssl-for-clients), use:

```ruby
Ignite::Client.new(
  use_ssl: true,
  ssl_params: {
    ca_file: "ca.pem"
  }
)
```

Supports all OpenSSL params

## History

View the [changelog](https://github.com/ankane/ignite-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ignite-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ignite-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/ignite-ruby.git
cd ignite-ruby
bundle install
bundle exec rake test
```
