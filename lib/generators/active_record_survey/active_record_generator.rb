require "generators/active_record_survey/active_record_survey_generator"
require "generators/active_record_survey/next_migration_version"
require "rails/generators/migration"
require "rails/generators/active_record"

# Extend the HasDynamicColumnsGenerator so that it creates an AR migration
module ActiveRecordSurvey
	class ActiveRecordGenerator < ::ActiveRecordSurveyGenerator
		include Rails::Generators::Migration
		extend NextMigrationVersion

		source_paths << File.join(File.dirname(__FILE__), "templates")

		def create_migration_file
			migration_template "migration_0.1.0.rb", "db/migrate/add_active_record_survey.rb"
		end

		def self.next_migration_number(dirname)
			::ActiveRecord::Generators::Base.next_migration_number dirname
		end
	end
end
