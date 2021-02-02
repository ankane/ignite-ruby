module Ignite
  class Cache
    attr_reader :cache_id, :client, :name

    def initialize(client, name)
      @client = client
      @name = name
      @cache_id = hash_code(name)
    end

    def get(key)
      req = Request.new(OP_CACHE_GET)
      req.int cache_id
      req.byte 0
      req.data_object key

      res = client.send_request(req)
      res.read_data_object
    end

    def get_all(keys)
      req = Request.new(OP_CACHE_GET_ALL)
      req.int cache_id
      req.byte 0
      req.int keys.size
      keys.each do |key|
        req.data_object key
      end

      res = client.send_request(req)
      result = {}
      res.read_int.times do
        result[res.read_data_object] = res.read_data_object
      end
      result
    end

    def put(key, value)
      req = Request.new(OP_CACHE_PUT)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object value

      client.send_request(req)
      nil
    end

    def put_all(objects)
      req = Request.new(OP_CACHE_PUT_ALL)
      req.int cache_id
      req.byte 0
      req.int objects.size
      objects.each do |key, value|
        req.data_object key
        req.data_object value
      end

      client.send_request(req)
      nil
    end

    def key?(key)
      req = Request.new(OP_CACHE_CONTAINS_KEY)
      req.int cache_id
      req.byte 0
      req.data_object key

      client.send_request(req).read_bool
    end
    alias_method :contains_key, :key?

    def keys?(keys)
      req = Request.new(OP_CACHE_CONTAINS_KEYS)
      req.int cache_id
      req.byte 0
      req.int keys.size
      keys.each do |key|
        req.data_object key
      end

      client.send_request(req).read_bool
    end
    alias_method :contains_keys, :keys?

    def get_and_put(key, value)
      req = Request.new(OP_CACHE_GET_AND_PUT)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object value

      client.send_request(req).read_data_object
    end

    def get_and_replace(key, value)
      req = Request.new(OP_CACHE_GET_AND_REPLACE)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object value

      client.send_request(req).read_data_object
    end

    def get_and_remove(key)
      req = Request.new(OP_CACHE_GET_AND_REMOVE)
      req.int cache_id
      req.byte 0
      req.data_object key

      client.send_request(req).read_data_object
    end

    def put_if_absent(key, value)
      req = Request.new(OP_CACHE_PUT_IF_ABSENT)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object value

      client.send_request(req).read_bool
    end

    def get_and_put_if_absent(key, value)
      req = Request.new(OP_CACHE_GET_AND_PUT_IF_ABSENT)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object value

      client.send_request(req).read_data_object
    end

    def replace(key, value)
      req = Request.new(OP_CACHE_REPLACE)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object value

      client.send_request(req).read_bool
    end

    def replace_if_equals(key, compare, value)
      req = Request.new(OP_CACHE_REPLACE_IF_EQUALS)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object compare
      req.data_object value

      client.send_request(req).read_bool
    end

    def clear
      req = Request.new(OP_CACHE_CLEAR)
      req.int cache_id
      req.byte 0

      client.send_request(req)
      nil
    end

    def clear_key(key)
      req = Request.new(OP_CACHE_CLEAR_KEY)
      req.int cache_id
      req.byte 0
      req.data_object key

      client.send_request(req)
      nil
    end

    def clear_keys(keys)
      req = Request.new(OP_CACHE_CLEAR_KEYS)
      req.int cache_id
      req.byte 0
      req.int keys.size
      keys.each do |key|
        req.data_object key
      end

      client.send_request(req)
      nil
    end

    def remove_key(key)
      req = Request.new(OP_CACHE_REMOVE_KEY)
      req.int cache_id
      req.byte 0
      req.data_object key

      client.send_request(req).read_bool
    end

    def remove_if_equals(key, compare)
      req = Request.new(OP_CACHE_REMOVE_IF_EQUALS)
      req.int cache_id
      req.byte 0
      req.data_object key
      req.data_object compare

      client.send_request(req).read_bool
    end

    # TODO add arguments
    def size
      req = Request.new(OP_CACHE_GET_SIZE)
      req.int cache_id
      req.byte 0
      req.int 0
      req.byte 0

      client.send_request(req).read_long
    end
    alias_method :get_size, :size

    def remove_keys(keys)
      req = Request.new(OP_CACHE_REMOVE_KEYS)
      req.int cache_id
      req.byte 0
      req.int keys.size
      keys.each do |key|
        req.data_object key
      end

      client.send_request(req)
      nil
    end

    def remove_all
      req = Request.new(OP_CACHE_REMOVE_ALL)
      req.int cache_id
      req.byte 0

      client.send_request(req)
      nil
    end

    def scan(page_size: 1000)
      return to_enum(:scan, page_size: page_size) unless block_given?

      # TODO filter
      filter = nil

      req = Request.new(OP_QUERY_SCAN)
      req.int cache_id
      req.byte 0
      req.data_object filter
      req.byte 0 unless filter.nil?
      req.int page_size
      req.int(-1)
      req.bool false

      res = client.send_request(req)
      cursor_id = res.read_long
      row_count = res.read_int
      row_count.times do
        yield res.read_data_object, res.read_data_object
      end
      more_results = res.read_bool

      while more_results
        req = Request.new(OP_QUERY_SCAN_CURSOR_GET_PAGE)
        req.long cursor_id

        # docs for OP_QUERY_SCAN_CURSOR_GET_PAGE response are incorrect
        # 1. no cursor_id
        # 2. row_count is int, not log
        res = client.send_request(req)
        row_count = res.read_int
        row_count.times do
          yield res.read_data_object, res.read_data_object
        end
        more_results = res.read_bool
      end
    end

    def get_or_create
      req = Request.new(OP_CACHE_GET_OR_CREATE_WITH_NAME)
      req.string name
      client.send_request(req)
      self
    end

    def destroy
      req = Request.new(OP_CACHE_DESTROY)
      req.int cache_id
      client.send_request(req)
      nil
    end

    private

    # same as Python
    # https://ignite.apache.org/docs/latest/binary-client-protocol/data-format#hash-code
    def hash_code(string)
      result = 0
      string.each_byte do |char|
        result = (((31 * result + char.ord) ^ 0x80000000) & 0xffffffff) - 0x80000000
      end
      result
    end
  end
end
