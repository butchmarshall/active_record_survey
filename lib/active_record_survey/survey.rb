module ActiveRecordSurvey
	class Survey < ::ActiveRecord::Base
		self.table_name = "active_record_surveys"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_id
		has_many :nodes, -> { distinct }, :through => :node_maps

		def questions
			self.node_maps.includes(:node).select { |i|
				i.node.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
			}.collect { |i|
				i.node
			}.uniq
		end

		def root_node
			self.node_maps.includes(:node).select { |i| i.depth === 0 }.first
		end

		def as_map
			list = self.node_maps

			list.select { |i| !i.parent }.collect { |i|
				i.as_map(list)
			}
		end

		# Build a question for this survey
		def build_question(question)
			# build_question only accepts a node that inherits from Question
			if !question.class.ancestors.include?(::ActiveRecordSurvey::Node::Question)
				raise ArgumentError.new "Question must inherit from ::ActiveRecordSurvey::Node::Question"
			end

			# Already added - shouldn't add twice
			if question.node_maps.select { |node_map|
				node_map.survey === self
			}.length > 0
				raise RuntimeError.new "This question has already been added to the survey"
			end

			question.node_maps.build(:node => question, :survey => self)
		end
	end
end