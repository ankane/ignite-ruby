# dependencies
require "bigdecimal"

# stdlib
require "date"
require "openssl"
require "socket"

# modules
require_relative "ignite/cache"
require_relative "ignite/op_codes"
require_relative "ignite/pack_formats"
require_relative "ignite/request"
require_relative "ignite/response"
require_relative "ignite/type_codes"
require_relative "ignite/version"

module Ignite
  class Error < StandardError; end
  class HandshakeError < Error; end
  class TimeoutError < Error; end
end
