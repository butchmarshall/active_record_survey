module ActiveRecordSurvey
	class Node::Question < Node
		# Stop validating at the Question node
		def validate_parent_instance_node(instance_node, child_node)
			!self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false)
		end

		# Build an answer off this node
		def build_answer(answer_node, survey)
			# Answers actually define how they're built off the parent node... yep
			answer_node.build_answer(self, survey)
		end
	end
end
