module ActiveRecordSurvey
	# Can hold a value on a scale (e.g. from 0-10)
	class Node::Answer::Scale < Node::Answer
		include Answer::Chained::InstanceMethods
		extend Answer::Chained::ClassMethods

		# Accept integer, float, or empty values
		def validate_instance_node(instance_node)
			# super - all validations on this node pass
			super &&
			(instance_node.value.to_s.empty? || !instance_node.value.to_s.match(/^(\d+(\.\d+)?)$/).nil?)
		end

		# Scale answers are considered answered if they have a value of greater than "0"
		def is_answered_for_instance?(instance)
			if instance_node = self.instance_node_for_instance(instance)
				# Answered if not empty and > 0
				!instance_node.value.to_s.empty? && instance_node.value.to_i >= 0
			else
				false
			end
		end
	end
end
