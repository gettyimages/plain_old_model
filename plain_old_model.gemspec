# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plain_old_model/version'

Gem::Specification.new do |gem|
  gem.name          = "plain_old_model"
  gem.version       = PlainOldModel::VERSION
  gem.authors       = ["Bhaskar Sundarraj", "Getty Images"]
  gem.email         = ["bhaskar.sundarraj@gmail.com","opensourcereview@gettyimages.com"]
  gem.description   = %q{This gem is created to cater the projects which do not require a backend/database,
  but still need some of the niceties offered by the ActiveRecord}
  gem.summary       = %q{This gem is created to cater the projects which do not require a backend/database,
    but still need some of the niceties offered by the ActiveRecord}
  gem.homepage      = ""
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'activesupport'
  gem.add_dependency 'activemodel'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-core'
end
