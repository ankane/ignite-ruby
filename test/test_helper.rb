require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

class Minitest::Test
  def client
    @client ||= begin
      if auth?
        Ignite::Client.new(username: "ignite", "password": "ignite", use_ssl: false)
      else
        Ignite::Client.new
      end
    end
  end

  def auth?
    ENV["IGNITE_AUTH"]
  end

  def cache
    @cache ||= client.get_or_create_cache("ignite_test")
  end
end
