require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

class Minitest::Test
  def client
    @client ||= Ignite::Client.new
  end

  def cache
    @cache ||= client.get_or_create_cache("ignite_test")
  end
end
