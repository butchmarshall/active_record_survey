require 'spec_helper'

describe ActiveRecordSurvey::Node::Question, :question_spec => true do
	describe 'a survey' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1")
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1, @survey)
			@q1.build_answer(@q1_a2, @survey)
			@q1.build_answer(@q1_a3, @survey)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2")
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
			@q2.build_answer(@q2_a1, @survey)
			@q2.build_answer(@q2_a2, @survey)

			@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3")
			@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #1")
			@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #2")
			@q3.build_answer(@q3_a1, @survey)
			@q3.build_answer(@q3_a2, @survey)

			@q4 = ActiveRecordSurvey::Node::Question.new(:text => "Question #4")
			@q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #1")
			@q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #2")
			@q4.build_answer(@q4_a1, @survey)
			@q4.build_answer(@q4_a2, @survey)

			# Link up Q1
			@q1_a1.build_link(@q2)
			@q1_a2.build_link(@q3)
			@q1_a3.build_link(@q4)

			# Link up Q2
			@q2_a1.build_link(@q4)
			@q2_a2.build_link(@q3)

			# Link up Q3
			@q3_a1.build_link(@q4)
			@q3_a2.build_link(@q4)

			@survey.save
		end

		describe '#answers' do
			it 'should return all the answers' do
				answers = @survey.questions.collect { |question|
					question.answers
				}.flatten

				expect(answers.length).to eq(9)
			end
		end

		describe '#build_answer', :focus => true do
			it 'should have the right number of node maps' do
				@survey = ActiveRecordSurvey::Survey.new()

				@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1")
				@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
				@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
				@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
				@q1.build_answer(@q1_a1, @survey)
				@q1.build_answer(@q1_a2, @survey)
				@q1.build_answer(@q1_a3, @survey)

				@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2")
				@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
				@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
				@q2.build_answer(@q2_a1, @survey)
				@q2.build_answer(@q2_a2, @survey)

				@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3")
				@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #1")
				@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #2")
				@q3.build_answer(@q3_a1, @survey)
				@q3.build_answer(@q3_a2, @survey)

				@q4 = ActiveRecordSurvey::Node::Question.new(:text => "Question #4")
				@q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #1")
				@q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #2")
				@q4.build_answer(@q4_a1, @survey)
				@q4.build_answer(@q4_a2, @survey)

				expect(@survey.node_maps.length).to eq(13)

				# Link up Q1
				@q1_a1.build_link(@q2)
				@q1_a2.build_link(@q3)
				@q1_a3.build_link(@q4)

				expect(@survey.node_maps.length).to eq(13)

				# Link up Q2
				@q2_a1.build_link(@q4)
				@q2_a2.build_link(@q3)

				expect(@survey.node_maps.length).to eq(19)

				# Link up Q3
				@q3_a1.build_link(@q4)
				@q3_a2.build_link(@q4)

				expect(@survey.node_maps.length).to eq(31)

				@q5 = ActiveRecordSurvey::Node::Question.new(:text => "Question #5")
				@q5_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #1")
				@q5_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #2")
				@q5_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #3")
				@q5_a4 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #4")
				@q5_a5 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #5")
				# Boolean builds the links differently! - it chains them so there is no branching choice
				@q5.build_answer(@q5_a1, @survey)
				@q5.build_answer(@q5_a2, @survey)
				@q5.build_answer(@q5_a3, @survey)
				@q5.build_answer(@q5_a4, @survey)
				@q5.build_answer(@q5_a5, @survey)

				@q4_a1.build_link(@q5)

				expect(@survey.node_maps.length).to eq(37)

				# Now - add an extra answer to Q1
				@q1_a4 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #4")
				@q1.build_answer(@q1_a4, @survey)

				expect(@survey.node_maps.length).to eq(38)

				@q1_a4.build_link(@q5)

				expect(@survey.node_maps.length).to eq(44)

				expect(@survey.as_map.as_json).to eq([{"text"=>"Question #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q1 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q2 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q2 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q1 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}]}])

				# Cannot build a link when a link already exists
				expect { @q1_a2.build_link(@q2) }.to raise_error RuntimeError

				# Remove the link
				@q1_a2.remove_link

				expect(@survey.as_map.as_json).to eq([{"text"=>"Question #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q1 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q2 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q2 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q1 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q1 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}]}, {"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}])

				@q1_a2.build_link(@q3)

				expect(@survey.as_map.as_json).to eq([{"text"=>"Question #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q1 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q2 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q2 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q1 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}]}])
			end
		end
	end
end