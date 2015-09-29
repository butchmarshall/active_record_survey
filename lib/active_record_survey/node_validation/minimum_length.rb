module ActiveRecordSurvey
	# Ensure the instance_node has a value greater than the minimum
	class NodeValidation::MinimumLength < NodeValidation
		# Validate the instance_node value is greater than the minimum
		def validate_instance_node(instance_node, answer_node = nil)
			is_valid = (instance_node.value.to_s.length >= self.value.to_i)

			instance_node.errors[:base] << { :nodes => { answer_node.id => ["MINIMUM_LENGTH"] } } if !is_valid

			is_valid
		end
	end
end
