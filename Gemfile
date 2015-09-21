source 'https://rubygems.org'

gem 'rake'

group :development, :test do
	activerecord_version = ENV['HAS_DYNAMIC_COLUMNS_ACTIVERECORD_VERSION']

	if ENV['RAILS_VERSION'] == 'edge' || activerecord_version == "edge"
		gem 'arel', :github => 'rails/arel'
		gem 'activerecord', :github => 'rails/rails'
	elsif activerecord_version && activerecord_version.strip != ""
		gem "activerecord", activerecord_version
	else
		gem 'activerecord', (ENV['RAILS_VERSION'] || ['>= 3.0', '< 5.0'])
	end

	gem 'coveralls', :require => false
	gem 'rspec', '>= 3'
	gem 'rubocop', '>= 0.25'
end

# Specify your gem's dependencies in active_record_survey.gemspec
gemspec
