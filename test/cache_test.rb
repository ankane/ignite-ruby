require_relative "test_helper"

class CacheTest < Minitest::Test
  def setup
    cache.clear
  end

  def test_get
    cache.put("k1", "v1")
    assert_equal "v1", cache.get("k1")
    assert_nil cache.get("k2")
  end

  def test_get_all
    cache.put_all({"k1" => "v1", "k2" => "v2"})
    assert_equal({"k1" => "v1"}, cache.get_all(["k1"]))
  end

  def test_put
    cache.put("k1", "v1")
    assert_equal "v1", cache.get("k1")
  end

  def test_put_all
    cache.put_all({"k1" => "v1", "k2" => "v2"})
    assert_equal({"k1" => "v1", "k2" => "v2"}, cache.get_all(["k1", "k2"]))
  end

  def test_contains_key
    cache.put("k1", "v1")
    assert cache.key?("k1")
    refute cache.key?("missing")
    assert cache.contains_key("k1")
    refute cache.contains_key("missing")
  end

  def test_contains_keys
    cache.put_all({"k1" => "v1", "k2" => "v2"})
    assert cache.keys?(["k1", "k2"])
    refute cache.keys?(["k1", "k3"])
    assert cache.contains_keys(["k1", "k2"])
    refute cache.contains_keys(["k1", "k3"])
  end

  def test_get_and_put
    assert_nil cache.get_and_put("k1", "v1")
    assert_equal "v1", cache.get_and_put("k1", "v2")
  end

  def test_get_and_replace
    assert_nil cache.get_and_replace("k1", "v1")
    assert_nil cache.get("k1")
    cache.put("k1", "v1")
    assert_equal "v1", cache.get_and_replace("k1", "v2")
    assert_equal "v2", cache.get("k1")
  end

  def test_get_and_remove
    assert_nil cache.get_and_remove("k1")
    cache.put("k1", "v1")
    assert_equal "v1", cache.get_and_remove("k1")
    refute cache.contains_key("k1")
  end

  def test_put_if_absent
    assert cache.put_if_absent("k1", "v1")
    refute cache.put_if_absent("k1", "v2")
    assert_equal "v1", cache.get("k1")
  end

  def test_get_and_put_if_absent
    assert_nil cache.get_and_put_if_absent("k1", "v1")
    assert_equal "v1", cache.get_and_put_if_absent("k1", "v2")
    assert_equal "v1", cache.get("k1")
  end

  def test_cache_replace
    assert_equal false, cache.replace("k1", "v1")
    assert_nil cache.get("k1")
    cache.put("k1", "v1")
    assert_equal true, cache.replace("k1", "v2")
    assert_equal "v2", cache.get("k1")
  end

  def test_cache_replace_if_equals
    cache.put("k1", "v1")
    assert_equal false, cache.replace_if_equals("k1", "not_equal", "v2")
    assert_equal true, cache.replace_if_equals("k1", "v1", "v3")
    assert_equal "v3", cache.get("k1")
  end

  def test_clear
    cache.put("k1", "v1")
    cache.clear
    refute cache.contains_key("k1")
  end

  def test_clear_key
    cache.put("k1", "v1")
    cache.clear_key("k1")
    refute cache.contains_key("k1")
  end

  def test_clear_keys
    cache.put_all({"k1" => "v1", "k2" => "v2", "k3" => "v3"})
    cache.clear_keys(["k1", "k2"])
    assert_equal({"k3" => "v3"}, cache.get_all(["k1", "k2", "k3"]))
  end

  def test_remove_key
    cache.put("k1", "v1")
    assert_equal true, cache.remove_key("k1")
    assert_equal false, cache.remove_key("k1")
  end

  def test_remove_if_equals
    cache.put("k1", "v1")
    assert_equal false, cache.remove_if_equals("k1", "v2")
    assert_equal true, cache.remove_if_equals("k1", "v1")
  end

  def test_get_size
    assert_equal 0, cache.size
    assert_equal 0, cache.get_size
    cache.put("k1", "v1")
    assert_equal 1, cache.size
    assert_equal 1, cache.get_size
  end

  def test_remove_keys
    cache.put_all({"k1" => "v1", "k2" => "v2", "k3" => "v3"})
    cache.remove_keys(["k1", "k2"])
    assert_equal({"k3" => "v3"}, cache.get_all(["k1", "k2", "k3"]))
  end

  def test_remove_all
    cache.put("k1", "v1")
    cache.remove_all
    refute cache.contains_key("k1")
  end

  def test_scan
    expected = {}
    20.times do |i|
      expected["k#{i}"] = "v#{i}"
    end
    cache.put_all(expected)
    actual = {}
    result = cache.scan(page_size: 6)
    result.each do |k, v|
      actual[k] = v
    end
    assert_equal expected, actual
  end

  def test_scan_block
    expected = {}
    20.times do |i|
      expected["k#{i}"] = "v#{i}"
    end
    cache.put_all(expected)
    actual = {}
    cache.scan do |k, v|
      actual[k] = v
    end
    assert_equal expected, actual
  end

  def test_destroy
    cache = client.get_or_create_cache("ignite_test_destroy")
    assert_includes client.caches.map(&:name), "ignite_test_destroy"
    cache.destroy
    refute_includes client.caches.map(&:name), "ignite_test_destroy"
  end
end
