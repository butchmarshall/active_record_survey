module ActiveRecordSurvey
	class Survey < ::ActiveRecord::Base
		self.table_name = "active_record_surveys"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_id, autosave: true
		has_many :nodes, -> { distinct }, :through => :node_maps
		has_many :questions, :class_name => "ActiveRecordSurvey::Node::Question", :foreign_key => :active_record_survey_id

		def root_node
			self.node_maps.includes(:node).select { |i| i.depth === 0 }.first
		end

		def as_map(*args)
			options = args.extract_options!
			options[:node_maps] ||= self.node_maps

			self.node_maps.select { |i| !i.parent && !i.marked_for_destruction? }.collect { |i|
				i.as_map(options)
			}
		end
	end
end