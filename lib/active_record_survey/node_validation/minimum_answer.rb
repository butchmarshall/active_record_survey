module ActiveRecordSurvey
	# Ensure the a minimum number of answers are made
	class NodeValidation::MinimumAnswer < NodeValidation
		# Validate the instance_node to ensure a minimum number of answers are made
		def validate_instance_node(instance_node, node = nil)
			!instance_node.value.to_s.empty? &&
			instance_node.value.to_f >= self.value.to_f
		end
	end
end
