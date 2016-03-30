module ActiveRecordSurvey
	class Node::Answer < Node
		# Answer nodes are valid if their questions are valid!
		# Validate this node against an instance
		def validate_node(instance)
			# Ensure each parent node to this node (the goal here is to hit a question node) is valid
			!self.survey.node_maps.select { |i|
				i.node == self
			}.collect { |node_map|
				node_map.parent.node.validate_node(instance)
			}.include?(false)
		end

		# Returns the question that preceeds this answer
		def question
			self.survey.node_maps.select { |i|
				i.node == self
			}.collect { |node_map|
				if node_map.parent && node_map.parent.node
					# Question is not the next parent - recurse!
					if node_map.parent.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
						node_map.parent.node.question
					else
						node_map.parent.node
					end
				# Root already
				else
					nil
				end
			}.first
		end

		# Returns the question that follows this answer
		def next_question
			self.survey.node_maps.select { |i|
				i.node == self && !i.marked_for_destruction?
			}.each { |answer_node_map|
				answer_node_map.children.each { |child|
					if !child.node.nil? && !child.marked_for_destruction?
						if child.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
							return child.node
						elsif child.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
							return child.node.next_question 
						end
					else
						return nil
					end
				}
			}
			return nil
		end

		# Removes the node_map from this answer to its next question
		def remove_link
			# not linked to a question - nothing to remove!
			return true if (question = self.next_question).nil?

			count = 0
			to_remove = []
			self.survey.node_maps.each { |node_map|
				if node_map.node == question
					if count > 0
						to_remove.concat(node_map.self_and_descendants)
					else
						node_map.parent = nil
					end
					count = count + 1
				end

				if node_map.node == self
					node_map.children = []
				end
			}
			self.survey.node_maps.each { |node_map|
				if to_remove.include?(node_map)
					node_map.parent = nil
					node_map.mark_for_destruction
				end
			}
		end

		def build_link(to_node)
			if self.question.nil?
				raise ArgumentError.new "A question is required before calling #build_link"
			end

			super(to_node)
		end

		# Gets index in sibling relationship
		def sibling_index
			if node_map = self.survey.node_maps.select { |i|
				i.node == self
			}.first

				node_map.parent.children.each_with_index { |nm, i|
					if nm == node_map
						return i
					end
				}
			end

			return 0
		end

		def sibling_index=index
			current_index = self.sibling_index

			offset = index - current_index

			(1..offset.abs).each { |i|
				self.send(((offset > 0)? "move_down" : "move_up"))
			}
		end

		# Moves answer up relative to other answers
		def move_up
			self.survey.node_maps.select { |i|
				i.node == self
			}.collect { |node_map|
				begin
					node_map.move_left
				rescue
				end
			}
		end

		# Moves answer down relative to other answers
		def move_down
			self.survey.node_maps.select { |i|
				i.node == self
			}.collect { |node_map|
				begin
					node_map.move_right
				rescue
				end
			}
		end

		private
			# By default - answers build off the original question node
			#
			# This allows us to easily override the answer building behaviour for different answer types
			def build_answer(question_node)
				self.survey = question_node.survey

				question_node_maps = self.survey.node_maps.select { |i| i.node == question_node && !i.marked_for_destruction? }

				# No node_maps exist yet from this question
				if question_node_maps.length === 0
					# Build our first node-map
					question_node_maps << self.survey.node_maps.build(:node => question_node, :survey => self.survey)
				end

				# Each instance of this question needs the answer hung from it
				question_node_maps.each { |question_node_map|
					question_node_map.children << self.survey.node_maps.build(:node => self, :survey => self.survey)
				}

				true
			end
	end
end
