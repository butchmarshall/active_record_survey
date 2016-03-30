module ActiveRecordSurvey
	class Node < ::ActiveRecord::Base
		self.table_name = "active_record_survey_nodes"
		belongs_to :survey, :class_name => "ActiveRecordSurvey::Survey", :foreign_key => :active_record_survey_id
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_node_id, autosave: true, dependent: :destroy
		has_many :node_validations, :class_name => "ActiveRecordSurvey::NodeValidation", :foreign_key => :active_record_survey_node_id, autosave: true, dependent: :destroy
		has_many :instance_nodes, :class_name => "ActiveRecordSurvey::InstanceNode", :foreign_key => :active_record_survey_node_id

		before_destroy :before_destroy_rebuild_node_map, prepend: true # prepend is important! otherwise dependent: :destroy on node<->node_map relation is executed first and no records!

		# All the answer nodes that follow from this node
		def answers
			self.survey.node_maps.select { |i|
				i.node == self
			}.collect { |i|
				# Get all the children from this node
				i.children
			}.flatten.collect { |i|
				# Get the nodes
				i.node
			}.select { |i|
				# Only the nodes that are answers
				i.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
			}.uniq.collect { |i|
				i.survey = self.survey # ensure that the survey being referenced by the answers is the original survey - needed for keeping consistent node_maps between build_link and remove_link
				[i] + i.answers
			}.flatten.uniq
		end

		# The instance_node recorded for the passed instance for this node
		def instance_node_for_instance(instance)
			instance.instance_nodes.select { |instance_node|
				(instance_node.node === self)
			}.first
		end

		# Whether this node has an answer recorded the instance
		def has_instance_node_for_instance?(instance)
			!self.instance_node_for_instance(instance).nil?
		end

		# Whether considered answered for instance
		#
		# Is answered is a little different than has_answer
		# Is answered is answer type specific, as what constitutes "answered" changes depending on
		# the question type asked (e.g. boolean is answered if "1")
		#
		# Each specific answer type should override this method if they have special criteria for answered
		#
		# default - if instance node exists, answered
		def is_answered_for_instance?(instance)
			self.has_instance_node_for_instance?(instance)
		end

		# Default behaviour is to recurse up the chain (goal is to hit a question node)
		def validate_parent_instance_node(instance_node, child_node)
			!self.survey.node_maps.select { |i| i.node == self}.collect { |node_map|
				if node_map.parent
					node_map.parent.node.validate_parent_instance_node(instance_node, self)
				# Hit top node
				else
					true
				end
			}.include?(false)
		end

		# Run all validations applied to this node
		def validate_instance_node(instance_node)
			# Basically this cache is messed up? Why? TODO.
			# Reloading in the spec seems to fix this... but... this could be a booby trap for others
			#self.node_validations(true)

			# Check the validations on this node against the instance_node
			validations_passed = !self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false)

			# More complex....
			# Recureses to the parent node to check
			# This is to validate Node::Question since they don't have instance_nodes directly to validate them
			parent_validations_passed = !self.survey.node_maps.select { |i| i.node == self}.collect { |node_map|
				if node_map.parent
					node_map.parent.node.validate_parent_instance_node(instance_node, self)
				# Hit top node
				else
					true
				end
			}.include?(false)

			validations_passed && parent_validations_passed
		end

		# Whether there is a valid answer path from this node to the root node for the instance
		def instance_node_path_to_root?(instance_node)
			instance_nodes = instance_node.instance.instance_nodes.select { |i| i.node === self }

			# if ::ActiveRecordSurvey::Node::Answer but no votes, not a valid path
			if self.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer) &&
				(instance_nodes.length === 0)
				return false
			end

			# Start at each node_map of this node
			# Find the parent node ma
			paths = self.survey.node_maps.select { |i| i.node == self }.collect { |node_map|
				# There is another level to traverse
				if node_map.parent
					node_map.parent.node.instance_node_path_to_root?(instance_node)
				# This is the root node - we made it!
				else
					true
				end
			}

			# If recursion reports back to have at least one valid path to root
			paths.include?(true)
		end

		# Build a link from this node to another node
		# Building a link actually needs to throw off a whole new clone of all children nodes
		def build_link(to_node)
			# build_link only accepts a to_node that inherits from Question
			if !to_node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
				raise ArgumentError.new "to_node must inherit from ::ActiveRecordSurvey::Node::Question"
			end

			if self.survey.nil?
				raise ArgumentError.new "A survey is required before calling #build_link"
			end

			from_node_maps = self.survey.node_maps.select { |i| i.node == self && !i.marked_for_destruction? }

			# Answer has already got a question - throw error
			if from_node_maps.select { |i|
				i.children.length > 0
			}.length > 0
				raise RuntimeError.new "This node has already been linked" 
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

				true
			end
	end
end