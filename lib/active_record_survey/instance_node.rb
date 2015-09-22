module ActiveRecordSurvey
	class InstanceNode < ::ActiveRecord::Base
		self.table_name = "active_record_survey_instance_nodes"
		belongs_to :instance, :class_name => "ActiveRecordSurvey::Instance", :foreign_key => :active_record_survey_instance_id
		belongs_to :node, :class_name => "ActiveRecordSurvey::Node", :foreign_key => :active_record_survey_node_id
		
		validates_presence_of :instance

		validate do |i|
			if !self.node.instance_path_to_root?(self.instance)
				i.errors[:base] << "MISSING_INSTANCE_NODE"
			end
		end
	end
end