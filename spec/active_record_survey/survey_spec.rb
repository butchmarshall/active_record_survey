require 'spec_helper'

describe ActiveRecordSurvey::Survey, :survey_spec => true do
	describe 'a survey' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)

			@q2 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Question #2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
			@q2.build_answer(@q2_a1)
			@q2.build_answer(@q2_a2)

			@q3 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Question #3", :survey => @survey)
			@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #1")
			@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #2")
			@q3.build_answer(@q3_a1)
			@q3.build_answer(@q3_a2)

			@q4 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Question #4", :survey => @survey)
			@q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #1")
			@q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #2")
			@q4.build_answer(@q4_a1)
			@q4.build_answer(@q4_a2)

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

		describe '#edges' do
			it 'should return an array of all the connective edges' do
				expect(@survey.edges.length).to eq(16)
			end
		end

		describe '#nodes' do
			it 'should return an array of all the nodes' do
				expect(@survey.nodes.length).to eq(13)
			end
		end

		describe '#questions' do
			it 'should return all the questions' do
				expect(@survey.questions.length).to be (4)
			end
		end

		describe ActiveRecordSurvey::Instance do
			it 'should allow valid instance_nodes to save' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q2_a2
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q3_a2
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q4_a2
				)
				instance.save
				expect(instance.valid?).to be(true)
			end

			it 'should prevent invalid instance_nodes from saving' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q2_a2
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q4_a2
				)
				instance.save
				expect(instance.valid?).to be(false)
			end

			it 'should allow only allow instance_nodes with one valid path' do
				instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a1
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q2_a2
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q3_a2
				)
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q4_a2
				)
				# This vote provides TWO paths
				instance.instance_nodes.build(
					:instance => instance,
					:node => @q1_a3
				)
				instance.save
				expect(instance.valid?).to be(false)
			end
		end
	end
end
