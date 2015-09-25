require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Text, :test => true do
	describe 'a text survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "What... what do you think?")
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Text.new()

			@survey.build_question(@q1, [@q1_a1])

			@survey.save
		end

		describe 'valid' do
			it 'when empty' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => ""
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'when not specified' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'when has content' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => "We have some content here!",
				)
				instance.save

				expect(instance.valid?).to be(true)
			end
		end

		describe ActiveRecordSurvey::NodeValidation::MinimumLength do
			describe 'valid when' do
				it 'has a value greater than the minimum' do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumLength.new(
						:node => @q1_a1,
						:value => 3
					)
					instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
					instance.instance_nodes.build(
						:instance => instance,
						:node => @q1_a1,
						:value => "this is greater than minimum length",
					)
					instance.save
	
					expect(instance.valid?).to be(true)
				end
			end

			describe 'invalid when' do
				it 'has a value less than the minimum' do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumLength.new(
						:node => @q1_a1,
						:value => 3
					)
					instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
					instance.instance_nodes.build(
						:instance => instance,
						:node => @q1_a1,
						:value => "12",
					)
					instance.save

					expect(instance.valid?).to be(false)
				end
			end
		end

		describe ActiveRecordSurvey::NodeValidation::MaximumLength do
			describe 'invalid when' do
				it 'has a value greater than the maximum' do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumLength.new(
						:node => @q1_a1,
						:value => 15
					)
					instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
					instance.instance_nodes.build(
						:instance => instance,
						:node => @q1_a1,
						:value => "123456789111213141516",
					)
					instance.save

					expect(instance.valid?).to be(false)
				end
			end

			describe 'valid when' do
				it 'has a value less than the maximum' do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumLength.new(
						:node => @q1_a1,
						:value => 15
					)
					instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
					instance.instance_nodes.build(
						:instance => instance,
						:node => @q1_a1,
						:value => "test",
					)
					instance.save

					expect(instance.valid?).to be(true)
				end
			end
		end
	end
end
