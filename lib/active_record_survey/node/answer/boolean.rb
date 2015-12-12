module ActiveRecordSurvey
	# Boolean answers can have values 0|1
	class Node::Answer::Boolean < Node::Answer
		include Answer::Chained

		# Only boolean values
		def validate_instance_node(instance_node)
			# super - all validations on this node pass
			super &&
			!instance_node.value.to_s.match(/^[0|1]$/).nil?
		end

		# Boolean answers are considered answered if they have a value of "1"
		def is_answered_for_instance?(instance)
			if instance_node = self.instance_node_for_instance(instance)
				# Instance node is answered "1"
				(instance_node.value.to_i === 1)
			end
		end
	end
end