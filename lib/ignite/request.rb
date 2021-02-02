module Ignite
  class Request
    MIN_LONG = -9223372036854775808 # -2**63
    MAX_LONG =  9223372036854775807 #  2**63-1

    def initialize(op_code)
      @format = String.new
      @values = []

      int 0 # length placeholder

      if op_code != OP_HANDSHAKE
        short op_code
        long rand(MIN_LONG..MAX_LONG) # request id
      end
    end

    # reduce allocations by packing together
    # but need to make sure values aren't modified
    # between when they are added and packed
    def to_bytes
      buffer = @values.pack(@format)
      # update length
      buffer[0..3] = [buffer.bytesize - 4].pack(PACK_INT)
      buffer
    end

    def bool(value)
      byte(value ? 1 : 0)
    end

    def byte(value)
      @format << PACK_BYTE
      @values << value
    end

    def short(value)
      @format << PACK_SHORT
      @values << value
    end

    def int(value)
      @format << PACK_INT
      @values << value
    end

    def long(value)
      @format << PACK_LONG
      @values << value
    end

    def float(value)
      @format << PACK_FLOAT
      @values << value
    end

    def double(value)
      @format << PACK_DOUBLE
      @values << value
    end

    def string(value)
      byte TYPE_STRING
      int value.bytesize
      @format << "a#{value.bytesize}"
      @values << value
    end

    def data_object(value)
      case value
      when Integer
        byte TYPE_LONG
        long value
      when Float
        byte TYPE_DOUBLE
        double value
      when TrueClass, FalseClass
        byte TYPE_BOOL
        bool value
      when String
        string value
      when Date
        byte TYPE_DATE
        time = value.to_time
        long(time.to_i * 1000 + (time.nsec / 1000000))
      when Array
        array_object(value)
      when Time
        byte TYPE_TIMESTAMP
        long(value.to_i * 1000 + (value.nsec / 1000000))
        int value.nsec % 1000000
      when NilClass
        byte TYPE_NULL
      else
        raise Error, "Unable to cache #{value.class.name}"
      end
    end

    def array_object(value)
      # empty arrays take first path for now
      if value.all? { |v| v.is_a?(Integer) }
        array(TYPE_LONG_ARRAY, value, PACK_LONG)
      elsif value.all? { |v| v.is_a?(Float) }
        array(TYPE_DOUBLE_ARRAY, value, PACK_DOUBLE)
      elsif value.all? { |v| v == true || v == false }
        array(TYPE_BOOL_ARRAY, value.map { |v| v ? 1 : 0 }, PACK_CHAR)
      else
        raise Error, "Unable to cache array of #{value.map { |v| v.class.name }.uniq.join(", ")}"
      end
    end

    def array(type_code, value, pack)
      byte type_code
      int value.size
      @format << "#{pack}#{value.size}"
      @values.concat(value)
    end
  end
end
