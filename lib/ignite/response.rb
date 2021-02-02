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
      raise "Expected string, not type #{type}" unless type == 9
      read_string
    end

    def read_date
      msecs_since_epoch = read_long
      sec = msecs_since_epoch / 1000
      Time.at(sec).to_date
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
      when 1
        read_byte
      when 2
        read_short
      when 3
        read_int
      when 4
        read_long
      when 5
        read_float
      when 6
        read_double
      when 7
        read_char
      when 8
        read_bool
      when 9
        read_string
      when 11
        read_date
      when 30
        read_decimal
      when 33
        read_timestamp
      when 101
        nil
      else
        raise Error, "Type not supported yet: #{type_code}. Please create an issue."
      end
    end
  end
end
