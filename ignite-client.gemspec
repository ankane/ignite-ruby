require_relative "lib/ignite/version"

Gem::Specification.new do |spec|
  spec.name          = "ignite-client"
  spec.version       = Ignite::VERSION
  spec.summary       = "Ruby client for Apache Ignite"
  spec.homepage      = "https://github.com/ankane/ignite-ruby"
  spec.license       = "Apache-2.0"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.6"
end
