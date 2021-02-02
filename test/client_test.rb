require_relative "test_helper"

class ClientTest < Minitest::Test
  def test_caches
    client.get_or_create_cache("ignite_test_name")
    assert_includes client.caches.map(&:name), "ignite_test_name"
  end

  def test_auth
    skip unless auth?

    error = assert_raises(Ignite::HandshakeError) do
      Ignite::Client.new
    end
    assert_equal "Unauthenticated sessions are prohibited.", error.message
  end
end
