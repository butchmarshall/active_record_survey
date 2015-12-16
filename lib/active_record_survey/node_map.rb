module ActiveRecordSurvey
	class NodeMap < ::ActiveRecord::Base
		self.table_name = "active_record_survey_node_maps"
		belongs_to :node, :foreign_key => :active_record_survey_node_id
		belongs_to :survey, :class_name => "ActiveRecordSurvey::Survey", :foreign_key => :active_record_survey_id
		acts_as_nested_set :scope => [:active_record_survey_id]

		validates_presence_of :survey

		# Recursively creates a copy of this entire node_map
		def recursive_clone
			node_map = self.survey.node_maps.build(:survey => self.survey, :node => self.node)
			self.children.each { |child_node|
				child_node.survey = self.survey # required due to voodoo - we want to use the same survey with the same object_id
				node_map.children << child_node.recursive_clone
			}
			node_map
		end

		def as_map(options)
			node_maps = options[:node_maps]

			c = (node_maps.nil?)? self.children : node_maps.select { |i|
				i.parent == self && !i.marked_for_destruction?
			}

			result = {}
			result.merge!({ :id => self.id, :node_id => self.node.id }) if !options[:no_ids]
			result.merge!({
				:type => self.node.class.to_s,
				:children => c.collect { |i|
					i.as_map(options)
				}
			})
			

			result
		end

		# Gets all the child nodes until one is not an ancestor of klass
		def children_until_node_not_ancestor_of(klass)
			if !self.node.class.ancestors.include?(klass)
				return []
			end

			[self] + self.children.collect { |i|
				i.children_until_node_not_ancestor_of(klass)
			}
		end

		# Check to see whether there is an infinite loop from this node_map
		def has_infinite_loop?(path = [])
			self.children.each { |i|
				# Detect infinite loop
				if path.include?(self.node) || i.has_infinite_loop?(path.clone.push(self.node))
					return true
				end
			}
			false
		end
		
		def mark_self_and_children_for_destruction
			removed = [self]
			self.mark_for_destruction
			self.children.each { |i|
				removed.concat(i.mark_self_and_children_for_destruction)
			}
			removed
		end
	end
end