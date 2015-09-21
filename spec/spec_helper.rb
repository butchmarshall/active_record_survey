require 'logger'
require 'rspec'
require 'factory_girl'

require 'active_record_survey'

# Trigger AR to initialize
ActiveRecord::Base

module Rails
  def self.root
    '.'
  end
end

# Add this directory so the ActiveSupport autoloading works
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

if RUBY_PLATFORM == 'java'
	ActiveRecord::Base.establish_connection :adapter => 'jdbcsqlite3', :database => ':memory:'
else
	ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
end

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
ActiveRecord::Migration.verbose = false

require "generators/active_record_survey/templates/migration_0.1.0"

ActiveRecord::Schema.define do
	AddActiveRecordSurvey.up
end

RSpec.configure do |config|
	config.include FactoryGirl::Syntax::Methods
	config.after(:each) do
	end
	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end