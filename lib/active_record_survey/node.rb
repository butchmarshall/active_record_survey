module ActiveRecordSurvey
	class Node < ::ActiveRecord::Base
		self.table_name = "active_record_survey_nodes"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_node_id
		has_many :node_validations, :class_name => "ActiveRecordSurvey::NodeValidation", :foreign_key => :active_record_survey_node_id, autosave: true
		has_many :instance_nodes, :class_name => "ActiveRecordSurvey::InstanceNode", :foreign_key => :active_record_survey_node_id

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

		# Run all validations applied to this node
		def validate_instance_node(instance_node)
			# UGH - so bsaically this validation doesn't know about the non-saved validation..
			#puts "Valdating #{self.id} - #{self.text} - total validations are - #{self.node_validations(true).length}"
			!self.node_validations.collect { |node_validation|
				node_validation.validate_instance_node(instance_node, self)
			}.include?(false) &&
			!self.node_maps.collect { |node_map|
				if node_map.parent
					node_map.parent.node.validate_instance_node(instance_node)
				# Hit top node
				else
					true
				end
			}.include?(false)
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