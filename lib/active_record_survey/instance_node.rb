module ActiveRecordSurvey
	class InstanceNode < ::ActiveRecord::Base
		self.table_name = "active_record_survey_instance_nodes"
		belongs_to :instance, :class_name => "ActiveRecordSurvey::Instance", :foreign_key => :active_record_survey_instance_id
		belongs_to :node, :class_name => "ActiveRecordSurvey::Node", :foreign_key => :active_record_survey_node_id
		
		validates_presence_of :instance

		validate do |i|
			#puts "\n---------------- Validating ------------------------"
			# If no instance node, 
			#i.errors[:base] << "NO_INSTANCE_NODE" if i.instance.nil?
			
			#puts self.instance.survey.as_map.inspect
			#puts self.instance.instance_nodes.inspect
			#puts "---------------- Done Validating ------------------------"
		end
	end
end