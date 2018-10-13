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
  spec.homepage      = "https://aliou.me"
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = '' if spec.respond_to?(:metadata)

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
