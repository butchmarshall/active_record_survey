module ActiveRecordSurvey
	# Boolean answers can have values 0|1
	class Node::Answer::Boolean < Node::Answer
		# Only boolean values
		def validate_instance_node(instance_node)
			!instance_node.value.to_s.match(/^[0|1]$/).nil?
		end
	end
end