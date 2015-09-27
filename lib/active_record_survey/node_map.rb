module ActiveRecordSurvey
	class NodeMap < ::ActiveRecord::Base
		self.table_name = "active_record_survey_node_maps"
		belongs_to :node, :foreign_key => :active_record_survey_node_id
		belongs_to :survey, :class_name => "ActiveRecordSurvey::Survey", :foreign_key => :active_record_survey_id
		acts_as_nested_set :scope => [:active_record_survey_id]
		
		after_initialize do |i|
			i.survey.node_maps << self if i.new_record?
		end

		def as_map(node_maps = nil)
			children = (node_maps.nil?)? self.children : node_maps.select { |i|
				i.parent == self
			}

			{
				:type => self.node.class.to_s,
				:text => "#{self.node.text}",
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
	end
end