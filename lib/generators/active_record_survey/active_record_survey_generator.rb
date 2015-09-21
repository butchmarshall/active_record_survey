require 'rails/generators/base'
require 'active_record_survey/compatibility'

class ActiveRecordSurveyGenerator < Rails::Generators::Base
	source_paths << File.join(File.dirname(__FILE__), 'templates')
end
