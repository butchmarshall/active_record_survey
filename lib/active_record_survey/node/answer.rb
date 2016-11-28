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
						node_map.move_to_root unless node_map.new_record?
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
			node_maps = self.survey.node_maps.includes(:node, parent: [:node])

			if node_map = node_maps.select { |i| i.node == self }.first
				parent = node_map.parent

				children = node_maps.select { |i| i.parent && i.parent.node === parent.node }

				children.each_with_index { |nm, i|
					if nm == node_map
						return i
					end
				}
			end
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
			# This allows us to easily override the answer removal behaviour for different answer types
			def remove_answer(question_node)
				#self.survey = question_node.survey

				# The node from answer from the parent question
				self.survey.node_maps.select { |i|
					!i.marked_for_destruction? &&
					i.node == self && i.parent && i.parent.node === question_node
				}.each { |answer_node_map|
					answer_node_map.send((answer_node_map.new_record?)? :destroy : :mark_for_destruction )
				}
			end

			# By default - answers build off the original question node
			#
			# This allows us to easily override the answer building behaviour for different answer types
			def build_answer(question_node)
				self.survey = question_node.survey

				answer_node_maps = self.survey.node_maps.select { |i|
					i.node == self && i.parent.nil?
				}.collect { |i|
					i.survey = self.survey

					i
				}

				question_node_maps = self.survey.node_maps.select { |i| i.node == question_node && !i.marked_for_destruction? }

				# No node_maps exist yet from this question
				if question_node_maps.length === 0
					# Build our first node-map
					question_node_maps << self.survey.node_maps.build(:node => question_node, :survey => self.survey)
				end

				# Each instance of this question needs the answer hung from it
				question_node_maps.each_with_index { |question_node_map, index|
					if answer_node_maps[index]
						new_node_map = answer_node_maps[index]
					else
						new_node_map = self.survey.node_maps.build(:node => self, :survey => self.survey)
					end

					question_node_map.children << new_node_map
				}

				true
			end
	end
end
