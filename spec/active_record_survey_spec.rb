require 'spec_helper'

describe ActiveRecordSurvey do
	it 'has a version number' do
		expect(ActiveRecordSurvey::VERSION).not_to be nil
	end

	it 'builds a survey that can be taken and only records valid answers', :focus => true do
		survey = ActiveRecordSurvey::Survey.new

		q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1")
		q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
		q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A2")
		q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A3")

		q2 = ActiveRecordSurvey::Node::Question.new(:text => "Q2")
		q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A1")
		q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A2")

		q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3")
		q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A1")
		q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A2")

		q4 = ActiveRecordSurvey::Node::Question.new(:text => "Q4")
		q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A1")
		q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A2")

		q1_nodes = survey.build_question(q1, [q1_a1, q1_a2, q1_a3])
		q2_nodes = survey.build_question(q2, [q2_a1, q2_a2], q1_nodes[1])
		q4_nodes = survey.build_question(q4, [q4_a1, q4_a2], q2_nodes[1])

		q3_nodes = survey.build_question(q3, [q3_a1, q3_a2], q2_nodes[2])
		q4_nodes = survey.build_question(q4, [q4_a1, q4_a2], q3_nodes[1])
		q4_nodes = survey.build_question(q4, [q4_a1, q4_a2], q3_nodes[2])

		q3_nodes = survey.build_question(q3, [q3_a1, q3_a2], q1_nodes[2])
		q4_nodes = survey.build_question(q4, [q4_a1, q4_a2], q3_nodes[1])
		q4_nodes = survey.build_question(q4, [q4_a1, q4_a2], q3_nodes[2])

		q4_nodes = survey.build_question(q4, [q4_a1, q4_a2], q1_nodes[3])

		survey.save

		# Take survey with valid path
		instance = ActiveRecordSurvey::Instance.new(:survey => survey)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q1_a1
		)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q2_a2
		)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q3_a2
		)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q4_a2
		)
		instance.save
		expect(instance.valid?).to be(true)

		# Take survey with invalid path
		instance = ActiveRecordSurvey::Instance.new(:survey => survey)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q1_a1
		)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q2_a2
		)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q4_a2
		)
		instance.save
		expect(instance.valid?).to be(false)

		# Take survey with valid path
		instance = ActiveRecordSurvey::Instance.new(:survey => survey)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q1_a3
		)
		instance.instance_nodes.build(
			:instance => instance,
			:node => q4_a1
		)
		instance.save
		expect(instance.valid?).to be(true)

	end
end
