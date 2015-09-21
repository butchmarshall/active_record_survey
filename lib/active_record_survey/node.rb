module ActiveRecordSurvey
	class Node < ::ActiveRecord::Base
		self.table_name = "active_record_survey_nodes"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_node_id
	end
end