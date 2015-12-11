module FactoryGirlSurveyHelpers
	extend self
	def build_basic_survey(survey)
		q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1")
		survey.build_question(q1)
		q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
		q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A2")
		q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A3")
		q1.build_answer(q1_a1)
		q1.build_answer(q1_a2)
		q1.build_answer(q1_a3)

		q2 = ActiveRecordSurvey::Node::Question.new(:text => "Q2")
		survey.build_question(q2)
		q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A1")
		q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A2")
		q2.build_answer(q2_a1)
		q2.build_answer(q2_a2)

		q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3")
		survey.build_question(q3)
		q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A1")
		q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A2")
		q3.build_answer(q3_a1)
		q3.build_answer(q3_a2)

		q4 = ActiveRecordSurvey::Node::Question.new(:text => "Q4")
		survey.build_question(q4)
		q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A1")
		q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A2")
		q4.build_answer(q4_a1)
		q4.build_answer(q4_a2)

		q5 = ActiveRecordSurvey::Node::Question.new(:text => "Q5 Boolean")
		survey.build_question(q5)
		q5_a1 = ActiveRecordSurvey::Node::Answer::Chain::Boolean.new(:text => "Q5 A1")
		q5_a2 = ActiveRecordSurvey::Node::Answer::Chain::Boolean.new(:text => "Q5 A2")
		q5.build_answer(q5_a1)
		q5.build_answer(q5_a2)

		q6 = ActiveRecordSurvey::Node::Question.new(:text => "Q6")
		survey.build_question(q6)
		q6_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q6 A1")
		q6_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q6 A2")
		q6.build_answer(q6_a1)
		q6.build_answer(q6_a2)

		# Link up Q1
		q1_a1.build_link(q2)
		q1_a2.build_link(q3)
		q1_a3.build_link(q4)

		# Link up Q2
		q2_a1.build_link(q4)
		q2_a2.build_link(q3)

		# Link up Q3
		q3_a1.build_link(q4)
		q3_a2.build_link(q4)

		# Link up Q4
		q4_a1.build_link(q6)
		q4_a2.build_link(q5)
		
		# Link up Q5
		q5_a2.build_link(q6)
	end
end

FactoryGirl.define do	
	factory :survey, :class => 'ActiveRecordSurvey::Survey' do |f|

	end

	factory :basic_survey, parent: :survey do |f|
		after(:build) { |survey| FactoryGirlSurveyHelpers.build_basic_survey(survey) }
	end
end