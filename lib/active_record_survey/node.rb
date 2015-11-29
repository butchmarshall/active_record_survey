module ActiveRecordSurvey
	class Node < ::ActiveRecord::Base
		self.table_name = "active_record_survey_nodes"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_node_id, autosave: true
		has_many :node_validations, :class_name => "ActiveRecordSurvey::NodeValidation", :foreign_key => :active_record_survey_node_id, autosave: true
		has_many :instance_nodes, :class_name => "ActiveRecordSurvey::InstanceNode", :foreign_key => :active_record_survey_node_id

		# All the answer nodes that follow from this node
		def answers
			self.node_maps.collect { |i|
				# Get all the children from this node
				i.children
			}.flatten.collect { |i|
				# Get the nodes
				i.node
			}.select { |i|
				# Only the nodes that are answers
				i.class.ancestors.include?(::ActiveRecordSurvey::Node::Answer)
			}.uniq.collect { |i|
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
			!self.node_maps.collect { |node_map|
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
			parent_validations_passed = !self.node_maps.collect { |node_map|
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
			paths = self.node_maps.collect { |node_map|
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
	end
end