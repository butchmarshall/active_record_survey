module ActiveRecordSurvey
	class Node::Question < Node
		# Stop validating at the Question node
		def validate_parent_instance_node(instance_node, child_node)
			!self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false)
		end

		# Updates the answers of this question to a different type
		def update_question_type(klass)
			if self.next_questions.length > 0
				raise RuntimeError.new "No questions can follow when changing the question type" 
			end

			nm = self.survey.node_maps

			self.answers.collect { |answer|
				nm.select { |i|
					i.node == answer
				}
			}.flatten.uniq.collect { |answer_node_map|
				answer_node_map.move_to_root
				answer_node_map.survey = self.survey

				answer_node_map
			}.collect { |answer_node_map|
				answer_node_map.node.type = klass.to_s
				answer_node_map.node = answer_node_map.node.becomes(klass)
				answer_node_map.node.survey = self.survey
				answer_node_map.node.save

				self.build_answer(answer_node_map.node)

				answer_node_map
			}
		end

		# Removes an answer
		def remove_answer(answer_node)
			# A survey must either be passed or already present in self.node_maps
			if self.survey.nil?
				raise ArgumentError.new "A survey must be passed if ActiveRecordSurvey::Node::Question is not yet added to a survey"
			end

			if !answer_node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
				raise ArgumentError.new "::ActiveRecordSurvey::Node::Answer not passed"
			end

			# Cannot mix answer types
			# Check if not match existing - throw error
			if !self.answers.include?(answer_node)
				raise ArgumentError.new "Answer not linked to question"
			end

			answer_node.send(:remove_answer, self)
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
			if answer_node.send(:build_answer, self)

				# If any questions existed directly following this question, insert after this answer
				self.survey.node_maps.select { |i|
					i.node == answer_node
				}.each { |answer_node_map|
					self.survey.node_maps.select { |j|
						# Same parent
						# Is a question
						j.parent == answer_node_map.parent && j.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
					}.each { |j|
						answer_node_map.survey = self.survey
						j.survey = self.survey

						answer_node_map.children << j
					}
				}

				true
			end
		end

		# Removes the node_map link from this question all of its next questions
		def remove_link
			return true if (questions = self.next_questions).length === 0

			# Remove the link to any direct questions
			self.survey.node_maps.select { |i|
				i.node == self
			}.each { |node_map|
				self.survey.node_maps.select { |j|
					node_map.children.include?(j) 
				}.each { |child|
					if child.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
						child.parent = nil
						child.send((child.new_record?)? :destroy : :mark_for_destruction )
					end
				}
			}

			# remove link any answeres that have questions
			self.answers.collect { |i|
				i.remove_link
			}
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

		private
			# Before a node is destroyed, will re-build the node_map links from parent to child if they exist
			# If a question is being destroyed and it has answers - don't link its answers - only parent questions that follow it
			def before_destroy_rebuild_node_map

				self.survey.node_maps.select { |i|
					i.node == self
				}.each { |node_map|
					# Remap all of this nodes children to the parent
					node_map.children.each  { |child|
						if !child.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
							node_map.parent.children << child
						end
					}
				}

				true
			end
	end
end