# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'bundler/setup'
require 'support/matchers/have_filter'
require 'json'
require 'faye'
require 'active_record'
require 'support/controller_macros'
require 'active_record/fixtures'
Bundler.setup

require 'thunderer'
RSpec.configure do |config|
  FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')


  ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
  )
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.raise_errors_for_deprecations!
  config.include ControllerMacros

  dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
  dep.autoload_paths.unshift FIXTURES_PATH

  ActiveRecord::Base.quietly do
    ActiveRecord::Migration.verbose = false
    load File.join(FIXTURES_PATH, 'schema.rb')
  end

  ActiveRecord::Fixtures.create_fixtures(FIXTURES_PATH, ActiveRecord::Base.connection.tables)

  config.order = 'random'
end
