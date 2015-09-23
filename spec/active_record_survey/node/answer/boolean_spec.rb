require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer::Boolean, :focus => true do
	describe 'a boolean survey is' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Please select one")
			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Dog")
			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Cat")
			@q1_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Mouse")

			nodes = @survey.build_question(@q1, [@q1_a1])
			nodes = @survey.build_question(@q1_a2, [], nodes[1])
			nodes = @survey.build_question(@q1_a3, [], nodes[0])

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

			it 'not answered in order' do
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
	end
end
