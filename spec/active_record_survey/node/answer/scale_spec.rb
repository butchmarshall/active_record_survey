require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Scale, :scale_spec => true do
	describe 'survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new(:survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Scale.new()
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Scale.new()
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Scale.new()

			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)

			@survey.save
		end

		describe 'valid when' do
			it 'accepts an integer value' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 100
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'accepts a float value' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
					:value => 10.5
				)
				instance.save

				expect(instance.valid?).to be(true)
			end

			it 'accepts an empty value' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1,
				)
				instance.save

				expect(instance.valid?).to be(true)
			end
		end

		describe 'invalid when' do
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

			it 'rejects when not answered in order' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a2,
					:value => 20
				)
				instance.save

				expect(instance.valid?).to be(false)
			end
		end

		describe ActiveRecordSurvey::NodeValidation do
			describe ActiveRecordSurvey::NodeValidation::MinimumAnswer do
				before(:all) do
					@q1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumAnswer.new(
						:node => @q1,
						:value => 1
					)

					# Weird caching is happening
					@q1_a1.reload
				end

				describe 'valid when' do
					it 'has a value greater than the minimum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 5,
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
						)
						instance.save
	
						expect(instance.valid?).to be(false)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MaximumAnswer do
				before(:all) do
					@q1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumAnswer.new(
						:node => @q1,
						:value => 2
					)

					# Weird caching is happening
					@q1_a1.reload
				end

				describe 'valid when' do
					it 'has a value less than the maximum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 8,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
							:value => 9,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
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
							:value => 8,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a2,
							:value => 9,
						)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a3,
							:value => 10,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MinimumValue do
				before(:all) do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumValue.new(
						:node => @q1_a1,
						:value => 4
					)
				end

				describe 'valid when' do
					it 'has a value greater than the minimum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 5,
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
							:value => 3,
						)
						instance.save
	
						expect(instance.valid?).to be(false)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MaximumValue do
				before(:all) do
					@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumValue.new(
						:node => @q1_a1,
						:value => 15
					)
				end

				describe 'valid when' do
					it 'has a value less than the maximum' do
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 8,
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
							:value => 20,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end
			end
		end
	end
end
