require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Boolean, :boolean_spec => true do
	describe '#build_answer' do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.new()
			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q2 Answer #1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q2 Answer #2")
			@q2_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q2 Answer #3")
			@q2.build_answer(@q2_a1)
			@q2.build_answer(@q2_a2)
			@q2.build_answer(@q2_a3)

			@q1_a3.build_link(@q2)

			@survey.save
		end

		it 'should append to last answer and fix chain to next question' do
			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q2 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}]}]}]}]}])

			@q1_a4 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q2 Answer #4")
			@q1.build_answer(@q1_a4)

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q2 Answer #4", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q2 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}]}]}]}]}]}])
		end
	end

	describe '#sibling_index' do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.new()
			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #3")
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
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@survey.save
		end

		describe '#sibling_index' do
			it 'should go higher if possible' do
				@q1_a3.sibling_index = 0

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])
			end

			it 'should go lower if possible' do
				@q1_a1.sibling_index = 2

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])
			end
		end

		describe '#move_up' do
			it 'should go higher of possible' do
				@q1_a2.move_up

				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])

				@q1_a3.move_up

				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])

				@survey.save
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])

				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])
			end

			it 'should not change the position of the first question' do
				@q1_a1.move_up

				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])

				# Save should not affect it
				@survey.save
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])

				# Reload should not affect it
				@survey.reload
				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])
			end
		end

		describe '#move_down' do
			it 'should go lower of possible' do
				@q1_a2.move_down

				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])
			end

			it 'should not change the position of the last question' do
				@q1_a3.move_down

				expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])
			end
		end
	end

	describe '#destroy' do
		it 'should re-link broken chains' do
			survey = ActiveRecordSurvey::Survey.new()
			q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => survey)
			q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #3")
			q1.build_answer(q1_a1)
			q1.build_answer(q1_a2)
			q1.build_answer(q1_a3)
			survey.save

			expect(survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}])

			q1_a2.destroy
			survey.reload # reload seems to be necessary

			expect(survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}])
		end
	end

	describe 'a boolean survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "A")
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "B")
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "C")
			@q1_a4 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "D")
			@q1_a5 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "E")

			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@q1.build_answer(@q1_a4)
			@q1.build_answer(@q1_a5)

			@survey.save
		end

		describe 'valid' do
			it 'when 1 is passed' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'when 0 is passed' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 0
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 1
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'when answered in order' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 0
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a3,
					:value => 0
				)
				instance.save

				expect(instance.valid?).to be(true)
			end
		end

		describe 'invalid' do
			it 'when non boolean values are passed' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 5
				)
				instance.save

				expect(instance.valid?).to be(false)
			end

			it 'when not answered in order' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 1
				)
				instance.save

				expect(instance.valid?).to be(false)
			end
		end

		describe ActiveRecordSurvey::NodeValidation do
			before(:all) do
				@q1.node_validations.build(
					:type => 'ActiveRecordSurvey::NodeValidation::MinimumAnswer',
					:node => @q1,
					:value => 1 # min 1 of the 3 answers must be "answered"
				)
				@q1.node_validations.build(
					:type => 'ActiveRecordSurvey::NodeValidation::MaximumAnswer',
					:node => @q1,
					:value => 3 # max 2 of the 3 answers must be "answered"
				)
				@q1.save

				# Weird caching is happening
				@q1_a1.reload
			end

			describe ActiveRecordSurvey::NodeValidation::MinimumAnswer do
				describe 'valid when' do
					it 'has a value greater than the minimum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
							:value => 0,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 1,
						)
						instance.save

						expect(instance.valid?).to be(true)
					end
				end

				describe 'invalid when' do
					it 'has a value less than the minimum' do
						@q1.node_validations(true)
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 0,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
							:value => 0,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 0,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MaximumAnswer do
				describe 'valid when' do
					it 'has a value less than the maximum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
							:value => 0,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a4,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a5,
							:value => 0,
						)
						instance.save

						expect(instance.valid?).to be(true)
					end
				end

				describe 'invalid when' do
					it 'has a value greater than the maximum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a4,
							:value => 1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a5,
							:value => 1,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end
			end
		end
	end
end
