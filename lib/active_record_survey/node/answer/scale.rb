module ActiveRecordSurvey
	# Can hold a value on a scale (e.g. from 0-10)
	class Node::Answer::Scale < Node::Answer
		# Accept integer, float, or empty values
		def validate_instance_node(instance_node)
			# super - all validations on this node pass
			super &&
			(instance_node.value.to_s.empty? || !instance_node.value.to_s.match(/^(\d+(\.\d+)?)$/).nil?)
		end

		# Scale answers are considered answered if they have a value of greater than "0"
		def is_answered_for_instance?(instance)
			if instance_node = self.instance_node_for_instance(instance)
				# Answered if not empty and > 0
				!instance_node.value.to_s.empty? && instance_node.value.to_i >= 0
			else
				false
			end
		end

		# Scale nodes are different - they must find the final scale node added and add to it
		def build_answer(question_node, survey)
			# No node_maps exist yet from this question
			if question_node.node_maps.length === 0
				# Build our first node-map
				question_node.node_maps.build(:node => question_node, :survey => survey)
			end

			last_in_chain = question_node.answers.last || question_node

			# Each instance of this question needs the answer hung from it
			last_in_chain.node_maps.each { |node_map|
				answer_node_map = self.node_maps.build(:node => self, :survey => survey)
				node_map.children << answer_node_map
			}

			true
		end
	end
end
