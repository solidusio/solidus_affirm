$:.push File.expand_path('../lib', __FILE__)
require 'solidus_affirm/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_affirm'
  s.version     = SolidusAffirm::VERSION
  s.summary     = 'Solidus extension for using Affirm in your store'
  s.description = s.summary

  s.required_ruby_version = ">= 2.1"

  s.author    = 'Peter Berkenbosch'
  s.email     = 'peter@stembolt.com'
  s.homepage  = 'https://stembolt.com/'
  s.license   = 'BSD-3'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'active_model_serializers', '~> 0.10'
  s.add_dependency 'affirm-ruby', '1.0.2'
  s.add_dependency 'solidus', ['>= 1.1', '< 3']

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '>= 0.38'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
