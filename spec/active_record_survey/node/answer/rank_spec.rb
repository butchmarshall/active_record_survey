require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Rank, :rank_spec => true do
	describe 'survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new(:survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Rank.new()
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Rank.new()
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Rank.new()
			@q1_a4 = ActiveRecordSurvey::Node::Answer::Rank.new()
			@q1_a5 = ActiveRecordSurvey::Node::Answer::Rank.new()

			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@q1.build_answer(@q1_a4)
			@q1.build_answer(@q1_a5)

			@survey.save
		end

		describe 'valid when' do
			it 'accepts an integer value' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'accepts an empty value (no rank given)' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'ranked at than maximum number of answers' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 5
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'all answers are ranked in the correct order' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 3
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a3,
					:value => 2
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a4,
					:value => 5
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a5,
					:value => 4
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'one answer is not ranked' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 3
				)
				# Refusal to rank a3
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a3
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a4,
					:value => 2
				)
				# Refusal to rank a5
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a5
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			# TODO - additional min and max answer required validation nodes... 
		end

		describe 'invalid when' do
			it 'rejects a float value' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1.5
				)
				instance.save

				expect(instance.valid?).to be(false)
			end

			it 'rejects an alphabetical value' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => "1a2"
				)
				instance.save

				expect(instance.valid?).to be(false)
			end

			it 'ranked 0' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 0
				)
				instance.save

				expect(instance.valid?).to be(false)
			end

			it 'ranked higher than maximum number of answers' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 6
				)
				instance.save

				expect(instance.valid?).to be(false)
			end

			it 'rejects when not answered in order' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 1
				)
				instance.save

				expect(instance.valid?).to be(false)
			end

			it 'all one answer is ranked in correctly' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 3
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a3,
					:value => 12
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a4,
					:value => 5
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a5,
					:value => 4
				)
				instance.save

				expect(instance.valid?).to be(false)
			end
		end

		describe ActiveRecordSurvey::NodeValidation	do
			before(:all) do
				@q1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumAnswer.new(
					:node => @q1,
					:value => 2 # min 1 of the 3 answers must be "answered"
				)
				@q1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumAnswer.new(
					:node => @q1,
					:value => 3 # max 2 of the 3 answers must be "answered"
				)

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
							:value => 2,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 3,
						)
						instance.save

						expect(instance.valid?).to be(true)
					end
				end

				describe 'invalid when' do
					it 'has a value less than the minimum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 1,
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
							:value => 2,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a4,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a5,
							:value => 3,
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
							:value => 2,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 3,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a4,
							:value => 4,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a5,
							:value => 5,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end
			end
		end
	end
end
