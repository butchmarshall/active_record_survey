module ActiveRecordSurvey
	class NodeMap < ::ActiveRecord::Base
		self.table_name = "active_record_survey_node_maps"
		belongs_to :node, :foreign_key => :active_record_survey_node_id
		belongs_to :survey, :class_name => "ActiveRecordSurvey::Survey", :foreign_key => :active_record_survey_id
		acts_as_nested_set :scope => [:active_record_survey_id]

		validates_presence_of :survey

		after_initialize do |i|
			# Required for all functions to work without creating
			i.survey.node_maps << self if i.new_record? && i.survey
		end

		# Recursively creates a copy of this entire node_map
		def recursive_clone
			node_map = self.node.node_maps.build(:survey => self.survey, :node => self.node)
			self.children.each { |child_node|
				node_map.children << child_node.recursive_clone
			}
			node_map
		end

		def as_map(node_maps = nil)
			children = (node_maps.nil?)? self.children : node_maps.select { |i|
				i.parent == self
			}

			{
				:id => self.id,
				:node_id => self.node.id,
				:type => self.node.class.to_s,
				:children => children.collect { |i|
					i.as_map(node_maps)
				}
			}
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
	end
end