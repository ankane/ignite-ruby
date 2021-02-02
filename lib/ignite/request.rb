module Ignite
  class Request
    MIN_LONG = -9223372036854775808 # -2**63
    MAX_LONG =  9223372036854775807 #  2**63-1

    def initialize(op_code)
      @buffer = String.new
      int 0 # length placeholder

      if op_code != OP_HANDSHAKE
        short op_code
        long rand(MIN_LONG..MAX_LONG) # request id
      end
    end

    def to_bytes
      # update length
      @buffer[0..3] = [@buffer.bytesize - 4].pack("i!<")
      @buffer
    end

    def bool(value)
      byte(value ? 1 : 0)
    end

    def byte(value)
      [value].pack("C", buffer: @buffer)
    end

    def short(value)
      [value].pack("s!<", buffer: @buffer)
    end

    def int(value)
      [value].pack("i!<", buffer: @buffer)
    end

    def long(value)
      [value].pack("l!<", buffer: @buffer)
    end

    def float(value)
      [value].pack("e", buffer: @buffer)
    end

    def double(value)
      [value].pack("E", buffer: @buffer)
    end

    def string(value)
      byte 9
      int value.bytesize
      @buffer << value
    end

    def data_object(value)
      case value
      when Integer
        byte 4
        long value
      when Float
        byte 6
        double value
      when TrueClass, FalseClass
        byte 8
        bool value
      when String
        string value
      when Date
        byte 11
        time = value.to_time
        long(time.to_i * 1000 + (time.nsec / 1000000))
      when Time
        byte 33
        long(value.to_i * 1000 + (value.nsec / 1000000))
        int value.nsec % 1000000
      when NilClass
        byte 101
      else
        raise Error, "Unable to cache #{value.class.name}"
      end
    end
  end
end
