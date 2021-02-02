require "ignite"

module Ignite
  class Client
    def initialize(host: "localhost", port: 10800, username: nil, password: nil, use_ssl: nil, ssl_params: {})
      @socket = TCPSocket.new(host, port)

      use_ssl = use_ssl.nil? ? (username || password) : use_ssl
      if use_ssl
        ssl_context = OpenSSL::SSL::SSLContext.new

        # very important!!
        # call set_params so default params are applied
        # (like min_version and verify_mode)
        ssl_context.set_params(ssl_params)

        @socket = OpenSSL::SSL::SSLSocket.new(@socket, ssl_context)
        @socket.sync_close = true
        @socket.connect
      end

      send_handshake(username, password)
    end

    def close
      @socket.close
    end

    def cache(name)
      Cache.new(self, name)
    end

    def get_or_create_cache(name)
      cache(name).get_or_create
    end

    def caches
      req = Request.new(OP_CACHE_GET_NAMES)

      res = send_request(req)
      cache_count = res.read_int
      cache_count.times.map { cache(res.read_string_object) }
    end

    def query(statement, args = [], schema: "PUBLIC", page_size: 1000, max_rows: nil, statement_type: :any, timeout: nil)
      statement_type = [:any, :select, :update].index(statement_type)
      raise ArgumentError, "Invalid statement type" unless statement_type

      schema = get_or_create_cache(schema)

      req = Request.new(OP_QUERY_SQL_FIELDS)
      req.int schema.cache_id
      req.byte 0
      req.string schema.name
      req.int page_size
      req.int(max_rows || -1)
      req.string statement
      req.int args.size
      args.each do |arg|
        req.data_object arg
      end
      req.byte statement_type
      req.bool false
      req.bool false
      req.bool false
      req.bool false
      req.bool false
      req.bool false
      req.long(timeout || 0)
      req.bool true

      res = send_request(req)
      cursor_id = res.read_long
      field_count = res.read_int
      field_names = []
      field_count.times do
        field_names << res.read_string_object
      end

      rows = []
      row_count = res.read_int
      row_count.times do
        row = {}
        field_names.each do |field_name|
          row[field_name] = res.read_data_object
        end
        rows << row
      end
      more_results = res.read_bool

      while more_results && (!max_rows || rows.size < max_rows)
        req = Request.new(OP_QUERY_SQL_FIELDS_CURSOR_GET_PAGE)
        req.long cursor_id

        res = send_request(req)
        row_count = res.read_int
        row_count.times do
          row = {}
          field_names.each do |field_name|
            row[field_name] = res.read_data_object
          end
          rows << row
        end
        more_results = res.read_bool
      end

      if max_rows && rows.size > max_rows
        rows.pop(rows.size - max_rows)
      end

      rows
    end

    def close_resource(resource_id)
      req = Request.new(OP_RESOURCE_CLOSE)
      req.long resource_id
      send_request(req)
      nil
    end

    # internal
    def read(len)
      @socket.read(len)
    end

    # internal
    def send_request(req)
      @socket.write(req.to_bytes)
      res = Response.new(self)
      check_header res
      res
    end

    private

    def check_header(res)
      _req_id = res.read_long
      status = res.read_int

      if status != OP_SUCCESS
        raise Error, res.read_string_object
      end
    end

    def send_handshake(username, password)
      req = Request.new(OP_HANDSHAKE)
      req.byte 1
      req.short 1
      req.short 2
      req.short 0
      req.byte 2
      if username || password
        req.string username
        req.string password
      end
      @socket.write(req.to_bytes)

      res = Response.new(self)
      check_handshake res
    end

    def check_handshake(res)
      status = res.read_byte
      if status != 1
        _server_version_major = res.read_short
        _server_version_minor = res.read_short
        _server_version_patch = res.read_short
        raise HandshakeError, res.read_string_object
      end
    end
  end
end
