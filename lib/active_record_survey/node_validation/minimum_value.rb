module ActiveRecordSurvey
	# Ensure the instance_node has a value greater than the minimum
	class NodeValidation::MinimumValue < NodeValidation
		# Validate the instance_node value is greater than the minimum
		def validate_instance_node(instance_node, node = nil)
			!instance_node.value.to_s.empty? &&
			instance_node.value.to_f >= self.value.to_f
		end
	end
end
