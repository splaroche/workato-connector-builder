#!/usr/bin/env gem build
# encoding: utf-8
# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'workato-connector-builder'
  spec.description = 'A tool for building Workato Connectors from multiple hash files'
  spec.summary = spec.description
  spec.authors = [ 'Steven Laroche', ]
  spec.version = '0.0.1.pre'
  spec.license = 'MIT'

  spec.files = Dir['bin/*', 'lib/**/*.rb', 'workato-connector-builder.gemspec', 'LICENSE']
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.bindir = 'bin'
  spec.require_paths = [ 'lib' ]
  spec.metadata = { 'issue_tracker' => 'https://www.github.com/johndoe/missing/issues' }


  spec.required_ruby_version= '>= 2.0.0'

  spec.add_runtime_dependency 'rubocop-ast', '~> 1.12'
  spec.add_runtime_dependency 'thor', '~> 1.1'

  spec.add_development_dependency 'rbs', '~> 1.6'
  spec.add_development_dependency 'rspec', '~> 3.10'
end
