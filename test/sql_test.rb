require_relative "test_helper"

class SqlTest < Minitest::Test
  def test_queries
    client.query("DROP TABLE IF EXISTS products")
    client.query("CREATE TABLE products (id INTEGER PRIMARY KEY, name CHAR(255))")

    products = ["Test 1", "Test 2", "Test 3"]
    products.each_with_index do |city, i|
      client.query("INSERT INTO products (id, name) VALUES (?, ?)", [i, city])
    end

    expected = [{"NAME"=>"Test 1"}, {"NAME"=>"Test 2"}, {"NAME"=>"Test 3"}]
    assert_equal expected, client.query("SELECT name FROM products ORDER BY name", page_size: 2)

    expected = [{"NAME"=>"Test 1"}, {"NAME"=>"Test 2"}]
    assert_equal expected, client.query("SELECT name FROM products ORDER BY name", max_rows: 2)
  end

  def test_args
    assert_equal 1, client.query("SELECT ? AS value", [1]).first["VALUE"]
  end

  def test_statement_type
    error = assert_raises(Ignite::Error) do
      client.query("CREATE TABLE users (id INTEGER PRIMARY KEY, name CHAR(255))", statement_type: :select)
    end
    assert_match "Given statement type does not match that declared by JDBC driver", error.message
  end

  def test_error
    error = assert_raises(Ignite::Error) do
      client.query("BAD")
    end
    assert_match "Failed to parse query", error.message
  end
end
