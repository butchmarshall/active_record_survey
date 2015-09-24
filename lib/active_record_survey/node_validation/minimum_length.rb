module ActiveRecordSurvey
	# Ensure the instance_node has a value greater than the minimum
	class NodeValidation::MinimumLength < NodeValidation
		# Validate the instance_node value is greater than the minimum
		def validate_instance_node(instance_node, node = nil)
			instance_node.value.to_s.length >= self.value.to_i
		end
	end
end
