module ActiveRecordSurvey
	# Ensure the instance_node has a length less than the maximum
	class NodeValidation::MaximumLength < NodeValidation
		# Validate the instance_node value
		def validate_instance_node(instance_node, node = nil)
			instance_node.value.to_s.length <= self.value.to_i
		end
	end
end
