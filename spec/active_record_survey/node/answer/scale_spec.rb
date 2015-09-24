require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Scale do
	describe 'survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Please select one")
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Scale.new(:text => "How much do you like dogs?")
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Scale.new(:text => "How much do you like cats?")
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Scale.new(:text => "How much do you like mice?")

			nodes = @survey.build_question(@q1, [@q1_a1])
			nodes = @survey.build_question(@q1_a2, [], nodes[1])
			nodes = @survey.build_question(@q1_a3, [], nodes[0])

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

			describe ActiveRecordSurvey::NodeValidation::MinimumValue do
				describe 'valid when' do
					it 'has a value greater than the minimum' do
						@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumValue.new(
							:node => @q1_a1,
							:value => 4
						)
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
						@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MinimumValue.new(
							:node => @q1_a1,
							:value => 6
						)
						instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
						instance.instance_nodes.build(
							:instance => instance,
							:node => @q1_a1,
							:value => 5,
						)
						instance.save

						expect(instance.valid?).to be(false)
					end
				end
			end

			describe ActiveRecordSurvey::NodeValidation::MaximumValue do
				describe 'valid when' do
					it 'has a value less than the maximum' do
						@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumValue.new(
							:node => @q1_a1,
							:value => 15
						)
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
						@q1_a1.node_validations << ActiveRecordSurvey::NodeValidation::MaximumValue.new(
							:node => @q1_a1,
							:value => 15
						)
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
	end
end
