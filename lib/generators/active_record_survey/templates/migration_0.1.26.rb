class Update_0_1_26_ActiveRecordSurvey < ActiveRecord::Migration
	def self.up
		add_column :active_record_survey_nodes, :active_record_survey_id, :integer
	end

	def self.down
		remove_column :active_record_survey_nodes, :active_record_survey_id
	end
end