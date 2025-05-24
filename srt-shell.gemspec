# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'srt/shell/version'

Gem::Specification.new do |spec|
  spec.name          = 'srt-shell'
  spec.version       = SRT::Shell::VERSION
  spec.authors       = ['skliew']
  spec.email         = ['skliew@gmail.com']
  spec.summary       = %q{An interactive shell to retime SRT files.}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/skliew/srt-shell'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'srt', "~> 0.1.3"
end
