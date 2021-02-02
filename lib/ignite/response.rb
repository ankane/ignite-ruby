module Ignite
  class Response
    attr_reader :client

    def initialize(client)
      @client = client

      # use buffer so errors don't leave unread data on socket
      len = client.read(SIZE_INT).unpack1(PACK_INT)
      @buffer = StringIO.new(client.read(len))
    end

    def read(len)
      @buffer.read(len)
    end

    def read_byte
      read(SIZE_BYTE).unpack1(PACK_BYTE)
    end

    def read_short
      read(SIZE_SHORT).unpack1(PACK_SHORT)
    end

    def read_int
      read(SIZE_INT).unpack1(PACK_INT)
    end

    def read_long
      read(SIZE_LONG).unpack1(PACK_LONG)
    end

    def read_float
      read(SIZE_FLOAT).unpack1(PACK_FLOAT)
    end

    def read_double
      read(SIZE_DOUBLE).unpack1(PACK_DOUBLE)
    end

    def read_char
      read(SIZE_CHAR).unpack1(PACK_CHAR)
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
      read_array(SIZE_BYTE, PACK_BYTE)
    end

    def read_long_array
      read_array(SIZE_LONG, PACK_LONG)
    end

    def read_double_array
      read_array(SIZE_DOUBLE, PACK_DOUBLE)
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

    private

    def read_array(size, pack)
      len = read_int
      read(len * size).unpack("#{pack}*")
    end
  end
end
