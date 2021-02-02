module Ignite
  class Response
    attr_reader :client

    def initialize(client)
      @client = client

      # use buffer so errors don't leave unread data on socket
      len = client.read(4).unpack1("i!<")
      @buffer = StringIO.new(client.read(len))
    end

    def read(len)
      @buffer.read(len)
    end

    def read_byte
      read(1).unpack1("C")
    end

    def read_short
      read(2).unpack1("s!<")
    end

    def read_int
      read(4).unpack1("i!<")
    end

    def read_long
      read(8).unpack1("l!<")
    end

    def read_float
      read(4).unpack1("e")
    end

    def read_double
      read(8).unpack1("E")
    end

    def read_char
      read(1).unpack1("c")
    end

    def read_bool
      read_byte != 0
    end

    def read_string
      len = read_int
      read(len)
    end

    def read_string_object
      type = read_byte
      raise Error, "Expected string, not type #{type}" unless type == TYPE_STRING
      read_string
    end

    def read_date
      msecs_since_epoch = read_long
      sec = msecs_since_epoch / 1000
      Time.at(sec).to_date
    end

    def read_byte_array
      len = read_int
      read(len).unpack("C*")
    end

    def read_long_array
      len = read_int
      read(len * 8).unpack("l!<*")
    end

    def read_double_array
      len = read_int
      read(len * 8).unpack("E*")
    end

    def read_bool_array
      read_byte_array.map { |v| v != 0 }
    end

    # same as Python
    def read_decimal
      scale = read_int
      length = read_int
      data = read(length).unpack("C*")

      sign = (data[0] & 0x80) != 0
      data[0] = data[0] & 0x7f

      result = 0
      data.reverse.each_with_index do |v, i|
        result += v * 0x100 ** i
      end

      result = result / BigDecimal("10") ** BigDecimal(scale)
      result = -result if sign
      result
    end

    def read_timestamp
      msecs_since_epoch = read_long
      msec_fraction_in_nsecs = read_int
      sec = msecs_since_epoch / 1000
      nsec = (msecs_since_epoch % 1000) * 1000000 + msec_fraction_in_nsecs
      Time.at(sec, nsec, :nanosecond)
    end

    def read_data_object
      type_code = read_byte
      case type_code
      when TYPE_BYTE
        read_byte
      when TYPE_SHORT
        read_short
      when TYPE_INT
        read_int
      when TYPE_LONG
        read_long
      when TYPE_FLOAT
        read_float
      when TYPE_DOUBLE
        read_double
      when TYPE_CHAR
        read_char
      when TYPE_BOOL
        read_bool
      when TYPE_STRING
        read_string
      when TYPE_DATE
        read_date
      when TYPE_BYTE_ARRAY
        read_byte_array
      when TYPE_LONG_ARRAY
        read_long_array
      when TYPE_DOUBLE_ARRAY
        read_double_array
      when TYPE_BOOL_ARRAY
        read_bool_array
      when TYPE_DECIMAL
        read_decimal
      when TYPE_TIMESTAMP
        read_timestamp
      when TYPE_NULL
        nil
      else
        raise Error, "Type not supported yet: #{type_code}. Please create an issue."
      end
    end
  end
end
