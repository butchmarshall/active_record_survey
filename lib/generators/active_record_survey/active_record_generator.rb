require "generators/has_dynamic_columns/has_dynamic_columns_generator"
require "generators/has_dynamic_columns/next_migration_version"
require "rails/generators/migration"
require "rails/generators/active_record"

# Extend the HasDynamicColumnsGenerator so that it creates an AR migration
module HasDynamicColumns
	class ActiveRecordGenerator < ::HasDynamicColumnsGenerator
		include Rails::Generators::Migration
		extend NextMigrationVersion

		source_paths << File.join(File.dirname(__FILE__), "templates")

		def create_migration_file
			migration_template "migration.rb", "db/migrate/add_has_dynamic_columns.rb"
		end

		def self.next_migration_number(dirname)
			::ActiveRecord::Generators::Base.next_migration_number dirname
		end
	end
end
