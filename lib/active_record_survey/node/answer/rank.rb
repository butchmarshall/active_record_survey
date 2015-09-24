module ActiveRecordSurvey
	# Rank in relation to parent/children
	class Node::Answer::Rank < Node::Answer
		# Accept integer or empty values
		def validate_instance_node(instance_node)
			# super - all validations on this node pass
			super &&
			(instance_node.value.to_s.empty? ||
			!instance_node.value.to_s.match(/^\d+$/).nil?)
		end
	end
end
