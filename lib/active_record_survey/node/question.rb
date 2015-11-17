module ActiveRecordSurvey
	class Node::Question < Node
		# Stop validating at the Question node
		def validate_parent_instance_node(instance_node, child_node)
			!self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false)
		end

		# Returns the survey to the question
		def survey
			if node_map = self.node_maps.first
				node_map.survey
			end
		end

		# Build an answer off this node
		def build_answer(answer_node, survey = nil)
			survey = survey || self.node_maps.select { |i|
				!i.survey.nil?
			}.collect { |i|
				i.survey
			}.first

			# A survey must either be passed or already present in node_maps
			if survey.nil?
				raise ArgumentError.new "A survey must be passed if Question is not yet added to a survey"
			end

			# Answers actually define how they're built off the parent node... yep
			answer_node.build_answer(self, survey)
		end
	end
end
