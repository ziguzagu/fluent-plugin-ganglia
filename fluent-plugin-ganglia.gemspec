# -*- mode:ruby -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-ganglia"
  gem.version       = "0.0.1"
  gem.authors       = ["Hiroshi Sakai"]
  gem.email         = ["ziguzagu@gmail.com"]
  gem.description   = %q{Fluentd output plugin to ganglia via gmond}
  gem.summary       = %q{Fluentd output plugin to ganglia via gmond}
  gem.homepage      = "https://github.com/ziguzagu/fluent-plugin-ganglia"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "fluentd"

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "gmetric"
end
