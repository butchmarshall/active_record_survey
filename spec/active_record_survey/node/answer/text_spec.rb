require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Text, :text_spec => true do
	describe 'a text survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new(:survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Text.new()
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Text.new()

			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)

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

		describe ActiveRecordSurvey::NodeValidation do
			describe ActiveRecordSurvey::NodeValidation::MaximumLength do
				before(:all) do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumLength.new(
						:node => @q1_a1,
						:value => 15
					)

					# Weird caching is happening
					@q1_a1.reload
				end

				describe 'invalid when' do
					it 'has a value greater than the maximum' do
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

			describe ActiveRecordSurvey::NodeValidation::MinimumLength do
				before(:all) do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumLength.new(
						:node => @q1_a1,
						:value => 5
					)

					# Weird caching is happening
					@q1_a1.reload
				end

				describe 'invalid when' do
					it 'has a value less than the minimum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => "1234",
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end

				describe 'valid when' do
					it 'has a value greater than the minimum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => "12345",
						)
						instance.save

						expect(instance.valid?).to be(true)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MaximumAnswer do
				before(:all) do
					@q1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumAnswer.new(
						:node => @q1,
						:value => 1
					)

					# Weird caching is happening
					@q1_a1.reload
				end

				describe 'invalid when' do
					it 'has more answers than the maximum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => "123456",
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => "abcdefg",
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end

				describe 'valid when' do
					it 'has less answers than the maximum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => "123456",
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
						)
						instance.save

						expect(instance.valid?).to be(true)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MinimumAnswer do
				before(:all) do
					@q1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumAnswer.new(
						:node => @q1,
						:value => 1
					)

					# Weird caching is happening
					@q1_a1.reload
				end

				describe 'invalid when' do
					it 'has less than the minimum number of answers' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end

				describe 'valid when' do
					it 'has greater than the minimum number of answers' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => "12345",
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
						)
						instance.save

						expect(instance.valid?).to be(true)
					end
				end
			end
		end
	end
end
