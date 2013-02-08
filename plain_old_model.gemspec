# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plain_old_model/version'

Gem::Specification.new do |gem|
  gem.name          = "plain_old_model"
  gem.version       = PlainOldModel::VERSION
  gem.authors       = ["Bhaskar Sundarraj"]
  gem.email         = ["bhaskar.sundarraj@gmail.com"]
  gem.description   = %q{This gem is created to cater the projects which do not require a backend/database,
  but still need all the niceties offered by the ActiveModel}
  gem.summary       = %q{This gem is created to cater the projects which do not require a backend/database,
    but still need all the niceties offered by the ActiveModel}
  gem.homepage      = ""
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib","examples","spec"]
  gem.add_dependency 'activesupport'
  gem.add_dependency 'activemodel'
  gem.add_dependency 'rake'
  gem.add_dependency 'rspec'
  gem.add_dependency 'rspec-core'
end
