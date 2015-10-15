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

		# Removes the link
		# TODO - does this work when saved??
		def remove_link
			self.node_maps.each { |answer_node_map|
				answer_node_map.children.each { |child|
					# Should not know about parent
					child.parent = nil
				}
				# Should not know about children
				answer_node_map.children = []
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
				raise RuntimeError.new "This answer has already been linked to a question"
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
				}.first

				# Set the child node of this node to a node
				from_with_no_children.children << to_without_parent
			end
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
