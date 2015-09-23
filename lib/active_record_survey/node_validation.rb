module ActiveRecordSurvey
	# Validations that should be run against a node
	class NodeValidation < ::ActiveRecord::Base
		self.table_name = "active_record_survey_node_validations"
		belongs_to :node, :class_name => "ActiveRecordSurvey::Node", :foreign_key => :active_record_survey_node_id
	end
end