module ActiveRecordSurvey
	# Boolean answers can have values 0|1
	class Node::Answer::Chain < Node::Answer

		def is_answered_for_instance?(instance)
			if instance_node = self.instance_node_for_instance(instance)
				# Instance node is answered "1"
				(instance_node.value.to_i === 1)
			end
		end

		# Chain nodes are different - they must find the final answer node added and add to it
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