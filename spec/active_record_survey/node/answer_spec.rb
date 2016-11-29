require 'spec_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe ActiveRecordSurvey::Node::Answer, :answer_spec => true do

	describe '#sibling_index' do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.new()
			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@survey.save
		end

		it 'should give the answers position relative to its sublings' do
			expect(@q1_a1.sibling_index).to eq(0)
			expect(@q1_a2.sibling_index).to eq(1)
			expect(@q1_a3.sibling_index).to eq(2)
		end
	end

	describe 'move operations' do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.new()
			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@survey.save
		end

		describe '#sibling_index' do
			it 'should go higher if possible' do
				@q1_a3.sibling_index = 0

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				@survey.save
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
			end

			it 'should go lower by one' do
				@q1_a1.sibling_index = 1
				@survey.reload
			end

			it 'should go lower if possible' do
				@q1_a1.sibling_index = 2

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				@survey.save
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
			end
		end

		describe '#move_up' do
			it 'should go higher if possible' do
				@q1_a2.move_up

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
			end

			it 'should not change the position of the first question' do
				@q1_a1.move_up

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
			end
		end

		describe '#move_down' do
			it 'should go lower if possible' do
				@q1_a2.move_down

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
			end

			it 'should not change the position of the last question' do
				@q1_a3.move_down

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
			end
		end
	end

	# When answer nodes are deleted should:
	#	- Clean upp node_maps
	#	- If chained, build a chain from parent -> child after removing self
	describe '#destroy' do
		it 'should clean up node maps' do
			survey = ActiveRecordSurvey::Survey.new()
			q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => survey)
			q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			q1.build_answer(q1_a1)
			q1.build_answer(q1_a2)
			q1.build_answer(q1_a3)
			survey.save

			expect(survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

			q1_a2.destroy
			survey.reload

			expect(survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
		end
	end

	describe "#build_link" do
		it 'should correctly move to root when all links link removed' do
			survey = ActiveRecordSurvey::Survey.new()

			q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => survey)
			q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			q1.build_answer(q1_a1)
			q1.build_answer(q1_a2)

			q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => survey)
			q2_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			q2_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			q2.build_answer(q2_a1)
			q2.build_answer(q2_a2)
			survey.save

			q1_a2.build_link(q2)

			q1_a2.remove_link

			q2_a2.build_link(q1)
		end
		it 'should not have to be saved to produce a valid #as_map' do
			survey = ActiveRecordSurvey::Survey.new()
			q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => survey)
			q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			q1.build_answer(q1_a1)
			q1.build_answer(q1_a2)
			q1.build_answer(q1_a3)

			q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => survey)
			q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
			q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
			q2.build_answer(q2_a1)
			q2.build_answer(q2_a2)

			q1_a1.build_link(q2)

			expect(survey.node_maps.length).to eq(7)
			expect(survey.as_map).to eq([{"text"=>"Question #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q2 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q1 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 Answer #3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

			q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3", :survey => survey)
			q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A1")
			q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A2")
			q3.build_answer(q3_a1)
			q3.build_answer(q3_a2)

			q1_a2.build_link(q3)

			expect(survey.node_maps.length).to eq(10)
			expect(survey.as_map).to eq([{"text"=>"Question #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q2 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q1 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q3 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q1 Answer #3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

			q4 = ActiveRecordSurvey::Node::Question.new(:text => "Q4", :survey => survey)
			q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A1")
			q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A2")
			q4.build_answer(q4_a1)
			q4.build_answer(q4_a2)

			# Link up Q1
			q1_a3.build_link(q4)
			expect(survey.node_maps.length).to eq(13)
			expect(survey.as_map).to eq([{"text"=>"Question #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q2 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q1 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q3 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q1 Answer #3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}])

			# Link up Q2
			q2_a1.build_link(q4)
			q2_a2.build_link(q3)

			# Link up Q3
			q3_a1.build_link(q4)
			q3_a2.build_link(q4)
			expect(survey.as_map).to eq([{"text"=>"Question #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q2 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q4", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 A2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}])
		end
	end

	describe 'a survey' do
		before(:each) do
			@survey = FactoryGirl.build(:basic_survey)
			@survey.save
		end

		describe '#build_link' do
			it 'should throw error when build_link creates an infinite loop' do
				survey = ActiveRecordSurvey::Survey.new()

				q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1", :survey => survey)
				q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
				q1.build_answer(q1_a1)

				q2 = ActiveRecordSurvey::Node::Question.new(:text => "Q2", :survey => survey)
				q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A1")
				q2.build_answer(q2_a1)

				q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3", :survey => survey)
				q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A1")
				q3.build_answer(q3_a1)

				q1_a1.build_link(q2)
				q2_a1.build_link(q3)
				expect{q3_a1.build_link(q1)}.to raise_error(RuntimeError) # This should throw exception
			end

			it 'should keep consistent number of nodes after calling #remove_link and #build_link' do
				survey = FactoryGirl.build(:simple_survey)
				survey.save

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(31)

				q = survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Question Linkable", :survey => survey)
				q_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Question Linkable Answer #1")
				q_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Question Linkable Answer #2")
				q.build_answer(q_a1)
				q.build_answer(q_a2)

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(34)

				# Find Q4 Answer #2
				q4_a2 = nil

				survey.questions.each { |q|
					if q.text == "Question #4"
						q.answers.each { |a|
							q4_a2 = a if a.text == "Q4 Answer #2"
						}
					end
				}

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(34)
				q4_a2.build_link(q)
				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(49)
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}])

				survey.save
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}])

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(49)
				survey.reload
				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(49)
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}])

				q4_a2.remove_link

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(34)
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}, {"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				survey.save
				survey.reload

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(34)
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}, {"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				q4_a2.build_link(q)
				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(49)
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}])

				survey.save
				survey.reload

				expect(survey.node_maps.select { |i| !i.marked_for_destruction? }.length).to eq(49)
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question Linkable", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question Linkable Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Question Linkable Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}])
			end

			it 'should be allowed before saving after calling #remove_link' do
				survey = ActiveRecordSurvey::Survey.new()

				q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1", :survey => survey)
				q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
				q1.build_answer(q1_a1)

				q2 = ActiveRecordSurvey::Node::Question.new(:text => "Q2", :survey => survey)
				q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3", :survey => survey)

				expect(survey.as_map).to eq([{"text"=>"Q1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

				q1_a1.build_link(q2)
				expect(q1_a1.next_question).to eq(q2)

				expect(survey.as_map).to eq([{"text"=>"Q1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}])

				q1_a1.remove_link
				expect(q1_a1.next_question).to eq(nil)

				expect(survey.as_map).to eq([{"text"=>"Q1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}, {"text"=>"Q2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}])

				q1_a1.build_link(q3)
				expect(q1_a1.next_question).to eq(q3)
				expect(survey.as_map).to eq([{"text"=>"Q1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}, {"text"=>"Q2", :id=>nil, :node_id=>nil, :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}])

				survey.save
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Q1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}, {"text"=>"Q2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}])
				survey.reload
				expect(survey.as_map(:no_ids => true)).to eq([{"text"=>"Q1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Q3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}, {"text"=>"Q2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}])
			end
		end

		describe '#remove_link' do
			it 'should only unlink the specified answer' do
				q4 = nil
				q4_a1 = nil
				q4_a2 = nil
				q5 = nil
				q5_a1 = nil
				q5_a2 = nil
				q6 = nil
				@survey.questions.each { |i|
					q4 = i if i.text == "Q4"
					q5 = i if i.text == "Q5 Boolean"
					q6 = i if i.text == "Q6"
				}

				q4.answers.each { |i|
					q4_a1 = i if i.text == "Q4 A1"
					q4_a2 = i if i.text == "Q4 A2"
				}
				q5.answers.each { |i|
					q5_a1 = i if i.text == "Q5 A1"
					q5_a2 = i if i.text == "Q5 A2"
				}

				expect(q4_a1.next_question).to eq(q6)
				expect(q5_a2.next_question).to eq(q6)

				q5_a2.remove_link
				q5_a2.save

				# q5_a2 should now have no next question
				expect(q5_a2.next_question).to eq(nil)

				q5_a2.reload
				expect(q5_a2.next_question).to eq(nil)

				# q4_a1 should have been left alone
				expect(q4_a1.next_question).to eq(q6)

				q4_a1.reload
				expect(q4_a1.next_question).to eq(q6)
			end
		end

		describe '#next_question' do
			it 'should not have a next question if not linked anywhere' do
				survey = FactoryGirl.build(:survey1)
				survey.save

				q2 = survey.questions.select { |i|
					i.text == "Question #2"
				}.first

				q2_a1 = q2.answers.select { |i|
					i.text == "Q2 Answer #1"
				}.first

				expect(q2_a1.next_question).to be(nil)
			end

			it 'should get the next question' do
				expected = {
					"Q1" => {
						"Q1 A1" => "Q2",
						"Q1 A2" => "Q3",
						"Q1 A3" => "Q4",
					},
					"Q2" => {
						"Q2 A1" => "Q4",
						"Q2 A2" => "Q3",
					},
					"Q3" => {
						"Q3 A1" => "Q4",
						"Q3 A2" => "Q4",
					},
					"Q4" => {
						"Q4 A1" => "Q6",
						"Q4 A2" => "Q5 Boolean",
					},
					"Q5 Boolean" => {
						"Q5 A1" => "Q6",
						"Q5 A2" => "Q6",
					},
					"Q6" => {
						"Q6 A1" => "",
						"Q6 A2" => ""
					}
				}

				@survey.questions.each_with_index { |question, question_index|
					question.answers.each_with_index { |answer, answer_index|
						next_question_text = "#{((answer.next_question)? answer.next_question.text : '')}"

						expect(next_question_text).to eq(expected[question.text][answer.text.to_s])
					}
				}
			end
		end
	end
end
