module ActiveRecordSurvey
	class Instance < ::ActiveRecord::Base
		self.table_name = "active_record_survey_instances"
		belongs_to :survey, :class_name => "ActiveRecordSurvey::Survey", :foreign_key => :active_record_survey_id
		has_many :instance_nodes, :class_name => "ActiveRecordSurvey::InstanceNode", :foreign_key => :active_record_survey_instance_id

		validates_associated :instance_nodes
	end
end