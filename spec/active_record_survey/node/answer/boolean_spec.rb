require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Boolean, :boolean_spec => true do
	describe 'a boolean survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new()
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new()
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new()
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new()
			@q1_a4 = ActiveRecordSurvey::Node::Answer::Boolean.new()
			@q1_a5 = ActiveRecordSurvey::Node::Answer::Boolean.new()

			@survey.build_question(@q1)
			@q1.build_answer(@q1_a1, @survey)
			@q1.build_answer(@q1_a2, @survey)
			@q1.build_answer(@q1_a3, @survey)
			@q1.build_answer(@q1_a4, @survey)
			@q1.build_answer(@q1_a5, @survey)

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
