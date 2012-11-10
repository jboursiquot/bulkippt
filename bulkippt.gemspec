# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bulkippt/version'

Gem::Specification.new do |gem|
  gem.name          = "bulkippt"
  gem.version       = Bulkippt::VERSION
  gem.authors       = ["Johnny Boursiquot"]
  gem.email         = ["jboursiquot@gmail.com"]
  gem.description   = %q{Imports bookmarks (url, title, etc) into your kippt.com account in bulk}
  gem.summary       = %q{Imports bookmarks (url, title, etc) into your kippt.com account in bulk}
  gem.homepage      = "https://github.com/jboursiquot/bulkippt"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'kippt','~> 1.1'

  gem.add_development_dependency 'rake','~> 0.9'
  gem.add_development_dependency 'rspec','~> 2.11'
  gem.add_development_dependency 'fivemat', '~> 1.1'
end
