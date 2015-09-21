module ActiveRecordSurvey
	class Survey < ::ActiveRecord::Base
		self.table_name = "active_record_surveys"
		has_many :node_maps, :class_name => "ActiveRecordSurvey::NodeMap", :foreign_key => :active_record_survey_id
		has_many :nodes, :through => :node_maps

		def root_node
			self.node_maps.includes(:node).select { |i| i.depth === 0 }.first
		end

		def as_map
			self.root_node.as_map(self.node_maps.includes(:node))
		end

		# Build a question with answers for this survey
		def build_question(question, answers = [], parent = nil)
			node_maps = []
			n_question = question.node_maps.build(:node => question, :survey => self)
			node_maps << n_question

			answers.each { |answer|
				n_answer = answer.node_maps.build(:node => answer, :survey => self)
				n_question.children << n_answer
				node_maps << n_answer
			}

			# If a parent node is passed, add it
			parent.children << n_question if !parent.nil?

			node_maps
		end
	end
end