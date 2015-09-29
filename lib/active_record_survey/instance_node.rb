module ActiveRecordSurvey
	class InstanceNode < ::ActiveRecord::Base
		self.table_name = "active_record_survey_instance_nodes"
		belongs_to :instance, :class_name => "ActiveRecordSurvey::Instance", :foreign_key => :active_record_survey_instance_id
		belongs_to :node, :class_name => "ActiveRecordSurvey::Node", :foreign_key => :active_record_survey_node_id

		validates_presence_of :instance

		validate do |instance_node|
			# This instance_node has no valid path to the root node
			if !self.node.instance_node_path_to_root?(self)
				instance_node.errors[:base] << "INVALID_PATH"
			end

			parent_nodes = self.node.node_maps.collect { |j| j.parent }

			# Two instance_nodes on the same node for this instance
			if self.instance.instance_nodes.select { |i|
					# And the two arrays
					# Two votes share a parent (this means a question has two answers for this instance)
					(i.node.node_maps.collect { |j| j.parent } & parent_nodes).length > 0
				}.length > 1
				instance_node.errors[:base] << "DUPLICATE_PATH"
			end

			# Validate against the associated node
			if !self.node.validate_instance_node(self)
				instance_node.errors[:base] << "INVALID"
			end
		end
	end
end