module ActiveRecordSurvey
	class Answer
		module Chained
			module ClassMethods
				def self.extended(base)
					base.before_destroy :before_destroy_rebuild_node_map, prepend: true # prepend is important! otherwise dependent: :destroy on node<->node_map relation is executed first and no records!
				end
			end

			module InstanceMethods
				# Gets index relative to other chained answers
				def sibling_index
					if node_map = self.survey.node_maps.select { |i|
						i.node == self
					}.first
						return node_map.ancestors_until_node_not_ancestor_of(::ActiveRecordSurvey::Node::Answer).length-1
					end

					return 0
				end

				# Chain nodes are different - they must find the final answer node added and add to it
				def build_answer(question_node)
					self.survey = question_node.survey

					question_node_maps = self.survey.node_maps.select { |i| i.node == question_node && !i.marked_for_destruction? }

					# No node_maps exist yet from this question
					if question_node_maps.length === 0
						# Build our first node-map
						question_node_maps << self.survey.node_maps.build(:node => question_node, :survey => self.survey)
					end

					last_answer_in_chain = (question_node.answers.last || question_node)

					# Each instance of this question needs the answer hung from it
					self.survey.node_maps.select { |i|
						i.node == last_answer_in_chain
					}.each { |node_map|
						node_map.children << self.survey.node_maps.build(:node => self, :survey => self.survey)
					}

					true
				end

				# Moves answer down relative to other answers by swapping parent and children
				def move_up
					# Ensure each parent node to this node (the goal here is to hit a question node) is valid
					!self.survey.node_maps.select { |i|
						i.node == self
					}.collect { |node_map|
						# Parent must be an answer - cannot move into the position of a Question!
						if !node_map.parent.nil? && node_map.parent.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
							# I know this looks overly complicated, but we need to always work with the survey.node_maps - never children/parent of the relation
							parent_node = self.survey.node_maps.select { |j|
								node_map.parent == j
							}.first

							parent_parent = self.survey.node_maps.select { |j|
								node_map.parent.parent == j
							}.first

							node_map.parent = parent_parent
							parent_parent.children << node_map

							self.survey.node_maps.select { |j|
								node_map.children.include?(j)
							}.each { |c|
								c.parent = parent_node
								parent_node.children << c
							}

							parent_node.parent = node_map
							node_map.children << parent_node
						end
					}
				end

				# Moves answer down relative to other answers by swapping parent and children
				def move_down
					# Ensure each parent node to this node (the goal here is to hit a question node) is valid
					!self.survey.node_maps.select { |i|
						i.node == self
					}.collect { |node_map|
						# Must have children to move lower!
						# And the children are also answers!
						if node_map.children.length > 0 && !node_map.children.select { |j| j.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer) }.empty?
							# I know this looks overly complicated, but we need to always work with the survey.node_maps - never children/parent of the relation
							parent_node = self.survey.node_maps.select { |j|
								node_map.parent == j
							}.first

							children = self.survey.node_maps.select { |j|
								node_map.children.include?(j)
							}

							children_children = self.survey.node_maps.select { |j|
								children.collect { |k| k.children }.flatten.include?(j)
							}

							children.each { |c|
								parent_node.children << c
							}

							children.each { |c|
								c.children << node_map
							}

							children_children.each { |i|
								node_map.children << i
							}
						end
					}
				end

				private
					# Before a node is destroyed, will re-build the node_map links from parent to child if they exist
					def before_destroy_rebuild_node_map

						# All the node_maps from this node
						self.survey.node_maps.select { |i|
							i.node == self
						}.each { |node_map|
							# Remap all of this nodes children to the parent
							node_map.children.each  { |child|
								node_map.parent.children << child
							}
						}
					end
			end
		end
	end
end