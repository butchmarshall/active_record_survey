module ActiveRecordSurvey
	class Node < ::ActiveRecord::Base
		self.table_name = "active_record_survey_nodes"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_node_id

		# Whether there is a valid answer path from this node to the root node for the instance
		def instance_path_to_root?(instance)
			# See if there is a vote on this node
			if instance.instance_nodes.select { |instance_node|	instance_node.node === self }.length === 0
				# If ::ActiveRecordSurvey::Node::Answer but no votes, not a valid path
				if self.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
					return false
				end
			end

			# Start at each node_map of this node
			# Find the parent node ma
			path = self.node_maps.collect { |node_map|
				# There is another level to traverse
				if node_map.parent
					node_map.parent.node.instance_path_to_root?(instance)
				# This is the root node - we made it!
				else
					true
				end
			}

			path.include?(true)
		end
	end
end