module ActiveRecordSurvey
	# Ensure the a maximum number of answers are made
	class NodeValidation::MaximumAnswer < NodeValidation
		# Validate the instance_node to ensure a maximum number of answers are made
		def validate_instance_node(instance_node, question_node = nil)
			#puts "-------------------------------------------"
			#puts "runnin min answer validation"
			
			# Only makes sense for questions to have minimum answers
			if !question_node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
				return false 
			end

			instance = instance_node.instance

			# Go through the node_map of this node
			total_answered = question_node.node_maps.collect { |question_node_map|
				# Get all children until a childs node isn't an answer
				question_node_map.children.collect { |i|
					i.children_until_node_not_ancestor_of(::ActiveRecordSurvey::Node::Answer)
				}.flatten.collect { |i|
					i.node.is_answered_for_instance?(instance)
				}
			}.flatten.select { |i| i }.count

			total_answered <= self.value.to_i
		end
	end
end
