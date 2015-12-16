require 'logger'
require 'rspec'
require 'factory_girl'

require 'active_record_survey'

require_relative '../spec/factories/active_record_survey/survey'

require 'database_cleaner'

# Trigger AR to initialize
ActiveRecord::Base

#ActiveRecord::Base.logger = Logger.new(STDOUT)

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
require "generators/active_record_survey/templates/migration_0.1.26"

ActiveRecord::Schema.define do
	AddActiveRecordSurvey.up
	Update_0_1_26_ActiveRecordSurvey.up

	# Make it easier when you can put text on things
	add_column :active_record_survey_nodes, :text, :string
end

module ActiveRecordSurveyNodeMap
	def self.extended(base)
		base.instance_eval do
			include InstanceMethods
			alias_method_chain :as_map, :text
		end
	end

	module InstanceMethods
		def as_map_with_text(node_maps = nil)
			result = {
				"text" => self.node.text
 			}
			result = result.merge(as_map_without_text(node_maps))

			result
		end
	end
end
ActiveRecordSurvey::NodeMap.send(:extend, ActiveRecordSurveyNodeMap)

RSpec.configure do |config|
	config.include FactoryGirl::Syntax::Methods
	config.after(:each) do
	end

	config.before(:suite) do
		DatabaseCleaner.strategy = :transaction
		DatabaseCleaner.clean_with(:truncation)
	end

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end