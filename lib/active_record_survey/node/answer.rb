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

		# Returns the question that preceeds this answer
		def question
			self.node_maps.collect { |node_map|
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
			self.node_maps.each { |answer_node_map|
				answer_node_map.children.each { |child|
					if !child.node.nil?
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

		attr_accessor :ancestor_marked_for_destruction
		protected :ancestor_marked_for_destruction

		before_save do |node|
			# ------------------------ WARNING ------------------------
			# This code is to support #remove_link which uses mark_for_destruction
			# This code is necessary to clean everything up.
			# Calling save on this answer won't automatically go to its next_question -> node_maps and clean everything up
			(@ancestor_marked_for_destruction || []).each { |i|
				i.destroy
			}
		end

		# Removes the link
		def remove_link
			@ancestor_marked_for_destruction ||= []

			# not linked to a question - nothing to remove!
			return true if (question = self.next_question).nil?

			self.node_maps.each_with_index { |answer_nm, answer_nm_i|
				answer_nm.children = answer_nm.children.select { |question_nm|
					# This node_map links to the question
					if question_nm.node === question
						question_nm.parent = nil
						if answer_nm_i > 0
							question_nm.mark_for_destruction
							@ancestor_marked_for_destruction << question_nm
						end
						false
					else
						true
					end
				}
			}
		end

		# Build a link from this node to another node
		# Building a link actually needs to throw off a whole new clone of all children nodes
		def build_link(to_node)
			# build_link only accepts a to_node that inherits from Question
			if !to_node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
				raise ArgumentError.new "to_node must inherit from ::ActiveRecordSurvey::Node::Question"
			end

			# Answer has already got a question - throw error
			if self.node_maps.select { |i|
				i.children.length === 0
			}.length === 0
				raise RuntimeError.new "This answer has already been linked" 
			end

			# Attempt to find an unused to_node node_map
			if !(to_without_parent = to_node.node_maps.select { |i| i.parent.nil? }.first)
				# no unused path exists
				# we need to recursively clone the existing path

				to_node_map = to_node.node_maps.first || to_node.node_maps.build(:node => to_node, :survey => self.node_maps.first.survey)

				# Add it to all the from_node_maps
				self.node_maps.each { |from_node_map|
					from_node_map.children << to_node_map.recursive_clone
				}
			else
				# Find the node map from this node that has no children
				from_with_no_children = self.node_maps.select { |i|
					i.children.length == 0
				}

				if from_with_no_children.length > 1
					to_node_map = to_node.node_maps.first || to_node.node_maps.build(:node => to_node, :survey => self.node_maps.first.survey)
				end

				from_with_no_children.each_with_index { |from_with_no_children, index|
					# Use up the node that hasn't been used yet
					if index === 0
						from_with_no_children.children << to_without_parent
					# We need to clone destinations for each of the subsequent
					else
						from_with_no_children.children << to_node_map.recursive_clone
					end
				}

				# TODO - check to make sure there is no path to itself
			end

			self.node_maps.each { |node_map|
				# There is a path from Q -> A that is a loop
				if node_map.has_infinite_loop?
					raise RuntimeError.new "Infinite loop detected"
				end
			}
		end

		# By default - answers build off the original question node
		#
		# This allows us to easily override the answer building behaviour for different answer types
		#
		def build_answer(question_node, survey)
			# No node_maps exist yet from this question
			if question_node.node_maps.length === 0
				# Build our first node-map
				question_node.node_maps.build(:node => question_node, :survey => survey)
			end

			# Each instance of this question needs the answer hung from it
			question_node.node_maps.each { |question_node_map|
				answer_node_map = self.node_maps.build(:node => self, :survey => survey)
				question_node_map.children << answer_node_map
			}

			true
		end
	end
end
