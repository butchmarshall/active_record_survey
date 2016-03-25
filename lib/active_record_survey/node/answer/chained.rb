module ActiveRecordSurvey
	class Answer
		module Chained
			module ClassMethods
				def self.extended(base)
					base.before_destroy :before_destroy_rebuild_node_map, prepend: true # prepend is important! otherwise dependent: :destroy on node<->node_map relation is executed first and no records!
				end
			end

			module InstanceMethods
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