require_relative "test_helper"

class CacheTypesTest < Minitest::Test
  def test_string
    assert_caches "hello"
  end

  def test_bool
    assert_caches true
    assert_caches false
  end

  def test_integer
    assert_caches 1
  end

  def test_float
    assert_caches 1.5
  end

  def test_date
    assert_caches Date.today
  end

  def test_timestamp
    assert_caches Time.now
  end

  def test_integer_array
    assert_caches [1, 2, 3]
  end

  def test_float_array
    assert_caches [1.1, 2.2, 3.3]
  end

  def test_bool_array
    assert_caches [true, false, true]
  end

  def test_nil
    error = assert_raises(Ignite::Error) do
      cache.put("k", nil)
    end
    assert_equal "Ouch! Argument cannot be null: val", error.message
  end

  def test_empty_array
    assert_caches []
  end

  def test_object
    error = assert_raises(Ignite::Error) do
      cache.put("k", Object.new)
    end
    assert_equal "Unable to cache Object", error.message
  end

  def test_object_array
    error = assert_raises(Ignite::Error) do
      cache.put("k", [Object.new])
    end
    assert_equal "Unable to cache array of Object", error.message
  end

  def assert_caches(value)
    cache.put("k", value)
    assert_equal value, cache.get("k")
  end
end
