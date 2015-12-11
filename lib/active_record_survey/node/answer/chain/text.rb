module ActiveRecordSurvey
	# Text answers are... text answers
	class Node::Answer::Chain::Text < Node::Answer::Chain
		# Text answers are considered answered if they have text entered
		def is_answered_for_instance?(instance)
			if instance_node = self.instance_node_for_instance(instance)
				# Answered if has text
				instance_node.value.to_s.strip.length > 0
			else
				false
			end
		end
	end
end
