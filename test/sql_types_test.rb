require_relative "test_helper"

class SqlTypesTest < Minitest::Test
  def test_string
    assert_type "world", "SELECT 'world'"
  end

  def test_bool
    assert_type true, "SELECT true"
  end

  def test_smallint
    assert_type 1, "SELECT CAST(1 AS SMALLINT)"
  end

  def test_int
    assert_type 1, "SELECT 1"
    assert_type 1, "SELECT CAST(1 AS INT)"
  end

  def test_bigint
    assert_type 1, "SELECT CAST(1 AS BIGINT)"
  end

  def test_float
    assert_type 1.5, "SELECT CAST(1.5 AS FLOAT)"
  end

  def test_double
    assert_type 1.5, "SELECT CAST(1.5 AS DOUBLE)"
  end

  def test_timestamp
    assert_kind_of Time, client.query("SELECT CURRENT_TIMESTAMP AS value").first["VALUE"]
  end

  def test_decimal
    assert_type BigDecimal("1.5"), "SELECT CAST(1.5 AS DECIMAL)"
    assert_type BigDecimal("-1.5"), "SELECT CAST(-1.5 AS DECIMAL)"
    assert_type BigDecimal("1234567890.12345678901234567890"), "SELECT CAST(1234567890.12345678901234567890 AS DECIMAL)"
    assert_type BigDecimal("0.0000000000123456789"), "SELECT CAST(0.0000000000123456789 AS DECIMAL)"
  end

  def assert_type(expected, expression)
    result = client.query("#{expression} AS value").first["VALUE"]
    if expected.is_a?(Float) && expected.nan?
      assert result.nan?
    else
      assert_equal expected, result
    end
    assert_equal expected.class, result.class
  end
end
