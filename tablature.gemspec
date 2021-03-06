lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tablature/version'

Gem::Specification.new do |spec|
  spec.name          = 'tablature'
  spec.version       = Tablature::VERSION
  spec.authors       = ['Aliou Diallo']
  spec.email         = ['code@aliou.me']

  spec.summary       = 'Rails + Postgres Partitions'
  spec.description   = 'Rails + Postgres Partitions'
  spec.homepage      = 'https://aliou.me'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'pg', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-instafail'

  spec.add_dependency 'activerecord', '>= 5.0.0'
  spec.add_dependency 'railties', '>= 5.0.0'
end
