require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer, :answer_spec => true do
	describe 'a survey' do
		before(:all) do
			@survey = FactoryGirl.build(:basic_survey)
			@survey.save
		end

		describe '#next_question' do
			it 'should get the next question' do
				expected = [
					["Q1 A1 -> Q2", 	"Q1 A2 -> Q3", 			"Q1 A3 -> Q4"],
					["Q2 A1 -> Q4", 	"Q2 A2 -> Q3"],
					["Q4 A1 -> Q6", 	"Q4 A2 -> Q5 Boolean"],
					["Q6 A1 -> ", 		"Q6 A2 -> "],
					["Q3 A1 -> Q4", 	"Q3 A2 -> Q4"],
					["Q5 A1 -> Q6", 	"Q5 A2 -> Q6"],
				]

				@survey.questions.each_with_index { |question, question_index|
					question.answers.each_with_index { |answer, answer_index|
						actual = "#{answer.text} -> #{((answer.next_question)? answer.next_question.text : '')}"

						expect(actual).to eq(expected[question_index][answer_index])
					}
				}
			end
		end
	end
end
