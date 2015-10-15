module ActiveRecordSurvey
	# Rank in relation to parent/children of ActiveRecordSurvey::Node::Answer::Rank
	class Node::Answer::Rank < Node::Answer
		# Accept integer or empty values
		# Must be within range of the number of ranking nodes
		def validate_instance_node(instance_node)
			# super - all validations on this node pass
			super &&
			(instance_node.value.to_s.empty? || !instance_node.value.to_s.match(/^\d+$/).nil?) &&
			(instance_node.value.to_s.empty? || instance_node.value.to_i >= 1) &&
			instance_node.value.to_i <= self.max_rank
		end

		# Rank answers are considered answered if they have a value of greater than "0"
		def is_answered_for_instance?(instance)
			if instance_node = self.instance_node_for_instance(instance)
				# Answered if > 0
				instance_node.value.to_i > 0
			end
		end

		# Rank nodes are different - they must find the final rank node added and add to it
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

		protected

		# Calculate the number of Rank nodes above this one
		def num_above
			count = 0
			self.node_maps.each { |i|
				# Parent is one of us as well - include it and check its parents
				if i.parent.node.class.ancestors.include?(self.class)
					count = count + 1 + i.parent.node.num_above
				end
			}
			count
		end

		# Calculate the number of Rank nodes below this one
		def num_below
			count = 0
			self.node_maps.each { |node_map|
				node_map.children.each { |child|
					# Child is one of us as well - include it and check its children
					if child.node.class.ancestors.include?(self.class)
						count = count + 1 + child.node.num_below
					end
				}
			}
			count
		end

		# Calculate the maximum rank value that is accepted
		def max_rank
			self.num_above + self.num_below + 1
		end
	end
end
