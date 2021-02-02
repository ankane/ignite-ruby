# stdlib
require "bigdecimal"
require "date"
require "openssl"
require "socket"

# modules
require "ignite/cache"
require "ignite/op_codes"
require "ignite/request"
require "ignite/response"
require "ignite/type_codes"
require "ignite/version"

module Ignite
  class Error < StandardError; end
  class HandshakeError < Error; end
end
