module ActiveRecordSurvey
	# Ensure the instance_node has a value less than the maximum
	class NodeValidation::MaximumValue < NodeValidation
		# Validate the instance_node value is less than the maximum
		def validate_instance_node(instance_node, node = nil)
			!instance_node.value.to_s.empty? &&
			instance_node.value.to_f <= self.value.to_f
		end
	end
end
