module ActiveRecordSurvey
	# Can hold a value on a scale (e.g. from 0-10)
	class Node::Answer::Scale < Node::Answer
		# Accept integer, float, or empty values
		def validate_instance_node(instance_node)
			# super - all validations on this node pass
			super &&
			(instance_node.value.to_s.empty? || !instance_node.value.to_s.match(/^(\d+(\.\d+)?)$/).nil?)
		end
	end
end
