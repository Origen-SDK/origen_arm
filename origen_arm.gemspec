# coding: utf-8
config = File.expand_path('../config', __FILE__)
require "#{config}/version"

Gem::Specification.new do |spec|
  spec.name          = "origen_arm"
  spec.version       = OrigenARM::VERSION
  spec.authors       = ["Corey Engelken"]
  spec.email         = ["coreyengelken@gmail.com"]
  spec.summary       = "Origen subblocks modeling ARM cores."
  spec.homepage      = "https://origen-sdk.org/arm/"
  spec.license       = 'MIT'

  spec.required_ruby_version     = '>= 2'
  spec.required_rubygems_version = '>= 1.8.11'

  # Only the files that are hit by these wildcards will be included in the
  # packaged gem, the default should hit everything in most cases but this will
  # need to be added to if you have any custom directories
  spec.files         = Dir["lib/origen_arm.rb", "lib/origen_arm/**/*.rb", "templates/**/*", "config/**/*.rb",
                           "bin/*", "lib/tasks/**/*.rake", "pattern/**/*.rb",
                           "program/**/*.rb"
                          ]
  spec.executables   = []
  spec.require_paths = ["lib"]

  # Add any gems that your plugin needs to run within a host application
  spec.add_runtime_dependency "origen", ">= 0.41.2"
  
  spec.add_runtime_dependency "origen_testers", ">= 0.6.1"
  end
