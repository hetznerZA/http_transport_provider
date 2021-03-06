# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "http_transport_provider"
  spec.version       = "0.1.1"
  spec.authors       = ["Tiaan van Deventer"]
  spec.email         = ["tiaanvandeventer@gmail.com"]

  spec.summary       = %q{HTTP transport provider}
  spec.description   = %q{HTTP transport provider that makes use of the soar_transport_api}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'soar_transport_api', '~> 0.1.1'
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 2.1.0"
end
