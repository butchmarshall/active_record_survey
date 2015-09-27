module ActiveRecordSurvey
	class Node::Answer < Node
		# Answer nodes are valid if their questions are valid!
		# Validate this node against an instance
		def validate_node(instance)
			# Ensure each parent node to this node (the goal here is to hit a question node) is valid
			!self.node_maps.collect { |node_map|
				node_map.parent.node.validate_node(instance)
			}.include?(false)
		end
	end
end
