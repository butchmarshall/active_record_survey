module ActiveRecordSurvey
	# Ensure the instance_node has a length less than the maximum
	class NodeValidation::MaximumLength < NodeValidation
		# Validate the instance_node value
		def validate_instance_node(instance_node, answer_node = nil)
			is_valid = (self.value.to_i >= instance_node.value.to_s.length.to_i)

			instance_node.errors[:base] << { :nodes => { answer_node.id => ["MAXIMUM_LENGTH"] } } if !is_valid

			is_valid
		end
	end
end
