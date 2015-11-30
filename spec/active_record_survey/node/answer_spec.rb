require 'spec_helper'

describe ActiveRecordSurvey::Node::Answer, :answer_spec => true do
	describe 'a survey' do
		before(:each) do
			@survey = FactoryGirl.build(:basic_survey)
			@survey.save
		end

		describe '#remove_link', :focus => true do
			it 'should only unlink the specified answer' do
				
				q4 = nil
				q4_a1 = nil
				q4_a2 = nil
				q5 = nil
				q5_a1 = nil
				q5_a2 = nil
				q6 = nil
				@survey.questions.each { |i|
					q4 = i if i.text == "Q4"
					q5 = i if i.text == "Q5 Boolean"
					q6 = i if i.text == "Q6"
				}
				
				q4.answers.each { |i|
					q4_a1 = i if i.text == "Q4 A1"
					q4_a2 = i if i.text == "Q4 A2"
				}
				q5.answers.each { |i|
					q5_a1 = i if i.text == "Q5 A1"
					q5_a2 = i if i.text == "Q5 A2"
				}

				expect(q4_a1.next_question).to eq(q6)
				expect(q5_a2.next_question).to eq(q6)

				q5_a2.remove_link
				q5_a2.save

				# q5_a2 should now have no next question
				expect(q5_a2.next_question).to eq(nil)

				q5_a2.reload
				expect(q5_a2.next_question).to eq(nil)

				# q4_a1 should have been left alone
				expect(q4_a1.next_question).to eq(q6)

				q4_a1.reload
				expect(q4_a1.next_question).to eq(q6)
			end
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
