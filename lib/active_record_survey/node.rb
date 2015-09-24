module ActiveRecordSurvey
	class Node < ::ActiveRecord::Base
		self.table_name = "active_record_survey_nodes"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_node_id
		has_many :node_validations, :class_name => "ActiveRecordSurvey::NodeValidation", :foreign_key => :active_record_survey_node_id

		# By default all values are accepted
		def validate_instance_node(instance_node)
			!self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false)
		end

		# Whether there is a valid answer path from this node to the root node for the instance
		def instance_node_path_to_root?(instance_node)
			instance_nodes = instance_node.instance.instance_nodes.select { |i| i.node === self }

			# if ::ActiveRecordSurvey::Node::Answer but no votes, not a valid path
			if self.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer) &&
				(instance_nodes.length === 0)
				return false
			end

			# Start at each node_map of this node
			# Find the parent node ma
			paths = self.node_maps.collect { |node_map|
				# There is another level to traverse
				if node_map.parent
					node_map.parent.node.instance_node_path_to_root?(instance_node)
				# This is the root node - we made it!
				else
					true
				end
			}

			# If recursion reports back to have at least one valid path to root
			paths.include?(true)
		end
	end
end