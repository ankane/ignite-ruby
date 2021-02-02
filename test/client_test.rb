require_relative "test_helper"

class ClientTest < Minitest::Test
  def test_caches
    client.get_or_create_cache("ignite_test_name")
    assert_includes client.caches.map(&:name), "ignite_test_name"
  end
end
