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

		# Removes the link
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

		# Build a link from this node to another node
		# Building a link actually needs to throw off a whole new clone of all children nodes
		def build_link(to_node)
			# build_link only accepts a to_node that inherits from Question
			if !to_node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
				raise ArgumentError.new "to_node must inherit from ::ActiveRecordSurvey::Node::Question"
			end

			if self.question.nil?
				raise ArgumentError.new "A question is required before calling #build_link"
			end

			if self.survey.nil?
				raise ArgumentError.new "A survey is required before calling #build_link"
			end

			from_node_maps = self.survey.node_maps.select { |i| i.node == self && !i.marked_for_destruction? }

			# Answer has already got a question - throw error
			if from_node_maps.select { |i|
				i.children.length === 0
			}.length === 0
				raise RuntimeError.new "This answer has already been linked" 
			end

			# Because we need something to clone - filter this further below
			to_node_maps = self.survey.node_maps.select { |i| i.node == to_node && !i.marked_for_destruction? }

			if to_node_maps.first.nil?
				to_node_maps << self.survey.node_maps.build(:survey => self.survey, :node => to_node)
			end

			# Ensure we can through each possible path of getting to this answer
			to_node_map = to_node_maps.first
			to_node_map.survey = self.survey # required due to voodoo - we want to use the same survey with the same object_id

			# We only want node maps that aren't linked somewhere
			to_node_maps = to_node_maps.select { |i| i.parent.nil? }
			while to_node_maps.length < from_node_maps.length do
				to_node_maps.push(to_node_map.recursive_clone)
			end

			# Link unused node_maps to the new parents
			from_node_maps.each_with_index { |from_node_map, index|
				from_node_map.children << to_node_maps[index]
			}

			# Ensure no infinite loops were created
			from_node_maps.each { |node_map|
				# There is a path from Q -> A that is a loop
				if node_map.has_infinite_loop?
					raise RuntimeError.new "Infinite loop detected"
				end
			}
		end

		# Moves answer up relative to other answers
		def move_up
			!self.survey.node_maps.select { |i|
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
			!self.survey.node_maps.select { |i|
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
