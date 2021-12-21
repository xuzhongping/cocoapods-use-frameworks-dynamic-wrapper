# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-use-frameworks-dynamic-wrapper/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-use-frameworks-dynamic-wrapper'
  spec.version       = CocoapodsUseFrameworksDynamicWrapper::VERSION
  spec.authors       = ['nakahira']
  spec.email         = ['1021057927@qq.com']
  spec.summary       = %q{The CocoaPods plugin can automatically fix static framework transitive dependencies problems.}
  spec.homepage      = 'https://github.com/xuzhongping/cocoapods-use-frameworks-dynamic-wrapper'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*']
  spec.test_files    = spec.files.grep(%r{^(test|cocoapods-use-frameworks-dynamic-wrapper)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'cocoapods', '~> 1.0'
end