module ActiveRecordSurvey
	class Node::Question < Node
		# Stop validating at the Question node
		def validate_parent_instance_node(instance_node, child_node)
			!self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false)
		end

		# Build an answer off this node
		def build_answer(answer_node)
			# A survey must either be passed or already present in self.node_maps
			if self.survey.nil?
				raise ArgumentError.new "A survey must be passed if ActiveRecordSurvey::Node::Question is not yet added to a survey"
			end

			# Cannot mix answer types
			# Check if not match existing - throw error
			if !self.answers.select { |answer|
				answer.class != answer_node.class
			}.empty?
				raise ArgumentError.new "Cannot mix answer types on question"
			end

			# Answers actually define how they're built off the parent node
			answer_node.send(:build_answer, self)
		end

		# Returns the questions that follows this question (either directly or via its answers)
		def next_questions
			list = []

			if question_node_map = self.survey.node_maps.select { |i|
				i.node == self && !i.marked_for_destruction?
			}.first
				question_node_map.children.each { |child|
					if !child.node.nil? && !child.marked_for_destruction?
						if child.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
							list << child.node
						elsif child.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
							list << child.node.next_question 
						end
					end
				}
			end

			list.compact.uniq
		end
	end
end