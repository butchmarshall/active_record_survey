require 'spec_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe ActiveRecordSurvey::Node::Question, :question_spec => true do
	describe "#before_destroy_rebuild_node_map" do
		it 'should not relink any following questions' do
			@survey = ActiveRecordSurvey::Survey.new()
			@survey.save

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Answer #1a")
			@q1.build_answer(@q1_a1)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Answer #1b")
			@q2.build_answer(@q2_a1)

			@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3", :survey => @survey)
			@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Answer #1c")
			@q3.build_answer(@q3_a1)

			@q1_a1.build_link(@q2)
			@q2_a1.build_link(@q3)

			@survey.save

			@q2.destroy
			@survey.reload

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Answer #1a", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
		end

		it 'should relink any following questions' do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
			@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3", :survey => @survey)

			@survey.build_first_question(@q1)
			@q1.build_link(@q2)
			@q2.build_link(@q3)

			@survey.save

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}])

			@q2.destroy
			@survey.reload

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}])
		end
	end

	describe "#remove_answer" do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A2")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Q2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A2")
			@q2.build_answer(@q2_a1)
			@q2.build_answer(@q2_a2)

			@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3", :survey => @survey)
			@q3_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q3 A1")
			@q3_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q3 A1")
			@q3.build_answer(@q3_a1)
			@q3.build_answer(@q3_a2)

			@survey.save
		end

		it 'should remove the answer for regular answers' do
			expect(@q1.answers.length).to eq(2)

			@q1.remove_answer(@q1_a1)

			expect(@q1.answers.length).to eq(1)
		end

		it 'should remove the answer for boolean answers' do
			expect(@q3.answers.length).to eq(2)

			@q3.remove_answer(@q3_a1)

			@survey.save
			@survey.reload

			expect(@q3.answers.length).to eq(1)
		end

		it 'should remove the answer for boolean answers, and keep full question links' do
			@q3_a2.build_link(@q2)

			@survey.save
			@survey.reload

			expect(@q3.answers.length).to eq(2)
			expect(@q3.next_questions.length).to eq(1)

			@q3.remove_answer(@q3_a1)

			@survey.save
			@survey.reload

			expect(@q3.answers.length).to eq(1)
			expect(@q3.next_questions.length).to eq(1)
		end
	end

	describe "#update_question_type" do
		describe "simple case" do
			before(:each) do
				@survey = ActiveRecordSurvey::Survey.new()
	
				@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Q1", :survey => @survey)
				@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
				@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A2")
				@q1.build_answer(@q1_a1)
				@q1.build_answer(@q1_a2)
	
				@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Q2", :survey => @survey)
				@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A1")
				@q2.build_answer(@q2_a1)
	
				@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Q3", :survey => @survey)
				@q3_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q3 A1")
				@q3_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q3 A2")
				@q3.build_answer(@q3_a1)
				@q3.build_answer(@q3_a2)
	
				@survey.save
			end
			it 'should raise exception linked to another question' do
				@q1_a1.build_link(@q2)
				@survey.save
	
				expect{@q1.update_question_type(ActiveRecordSurvey::Node::Answer::Boolean)}.to raise_error(RuntimeError)
			end
			it 'should change ActiveRecordSurvey::Node::Answer to ActiveRecordSurvey::Node::Answer::Boolean' do
				@q1.update_question_type(ActiveRecordSurvey::Node::Answer::Boolean)
				expect(@survey.as_map(:no_ids => true)).to eq([{"text"=>"Q1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 A2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}, {"text"=>"Q2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 A1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}, {"text"=>"Q3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 A1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q3 A2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}])
				expect(@q1.answers.length).to eq(2)
				@q1.answers.each { |answer|
					expect(answer.class).to eq(ActiveRecordSurvey::Node::Answer::Boolean)
				}
			end
			it  'should change ActiveRecordSurvey::Node::Answer::Boolean to ActiveRecordSurvey::Node::Answer' do
				@q3.update_question_type(ActiveRecordSurvey::Node::Answer)
				expect(@survey.as_map(:no_ids => true)).to eq([{"text"=>"Q1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 A1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q1 A2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}, {"text"=>"Q2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 A1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}, {"text"=>"Q3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 A1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q3 A2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
				expect(@q3.answers.length).to eq(2)
				@q3.answers.each { |answer|
					expect(answer.class).to eq(ActiveRecordSurvey::Node::Answer)
				}
			end
		end
		describe "advanced case" do
			before(:each) do
				@survey = FactoryGirl.build(:basic_survey2)
				@survey.save
			end

			it "should convert from ActiveRecordSurvey::Node::Answer to ActiveRecordSurvey::Node::Answer::Boolean and back again" do
				q4 = nil
				@survey.questions.each {|question|
					q4 = question if question.text === "Question #4"
				}

				q4.update_question_type(ActiveRecordSurvey::Node::Answer::Boolean)
				expect(@survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[]}]}]}]}]}])

				q4.update_question_type(ActiveRecordSurvey::Node::Answer)
				expect(@survey.as_map(:no_ids => true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q2 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q2 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #3", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q3 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}, {"text"=>"Q3 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #4", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q4 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}, {"text"=>"Q4 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}]}]}])
			end
		end
	end

	describe "#remove_link" do
		it 'should remove the link between the question and child questions or answers child questions' do
			@survey = ActiveRecordSurvey::Survey.new()
			@survey.save

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@survey.build_first_question(@q1)
			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
			@q1.build_link(@q2)

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}])

			@q1.remove_link

			@survey.save
			@survey.reload

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}])

			@q1.build_link(@q2)

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}])

			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1.build_answer(@q1_a1)

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}])

			@q1.remove_link

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])

			@survey.save
			@survey.reload

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer", :children=>[]}]}])
		end
	end

	describe "#build_link" do
		it 'should build a link between two questions' do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@survey.build_first_question(@q1)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)

			@q1.build_link(@q2)

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}])
		end

		it 'should still allow answers to be inserted' do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@survey.build_first_question(@q1)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)

			@q1.build_link(@q2)

			@q1_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #1")
			@q1.build_answer(@q1_a1)

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}])

			@q1_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q1 Answer #2")
			@q1.build_answer(@q1_a2)

			@survey.save
			@survey.reload

			expect(@survey.as_map(no_ids: true)).to eq([{"text"=>"Question #1", :type=>"ActiveRecordSurvey::Node::Question", :children=>[{"text"=>"Q1 Answer #1", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Q1 Answer #2", :type=>"ActiveRecordSurvey::Node::Answer::Boolean", :children=>[{"text"=>"Question #2", :type=>"ActiveRecordSurvey::Node::Question", :children=>[]}]}]}]}])
		end
	end

	describe "#next_questions" do
		it "should return an array of all questions following a question, whether they have answers or not" do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			@q1_a4 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #4")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@q1.build_answer(@q1_a4)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
			@q2.build_answer(@q2_a1)
			@q2.build_answer(@q2_a2)

			@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3", :survey => @survey)
			@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #1")
			@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #2")
			@q3.build_answer(@q3_a1)
			@q3.build_answer(@q3_a2)

			@q4 = ActiveRecordSurvey::Node::Question.new(:text => "Question #4", :survey => @survey)
			@q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #1")
			@q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #2")
			@q4.build_answer(@q4_a1)
			@q4.build_answer(@q4_a2)

			@q5 = ActiveRecordSurvey::Node::Question.new(:text => "Question #5", :survey => @survey)

			@q6 = ActiveRecordSurvey::Node::Question.new(:text => "Question #6", :survey => @survey)
			@q6_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q6 Answer #1")
			@q6_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q6 Answer #2")
			@q6.build_answer(@q6_a1)
			@q6.build_answer(@q6_a2)

			@q7 = ActiveRecordSurvey::Node::Question.new(:text => "Question #7", :survey => @survey)

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

			# Link up Q1A4 -> Q5
			@q1_a4.build_link(@q5)

			# Link up Q5 -> Q6
			@q5.build_link(@q6)

			# Link up Q6 -> Q7
			@q6_a2.build_link(@q7)

			@survey.save

			q1_next_questions = @q1.next_questions
			q2_next_questions = @q2.next_questions
			q3_next_questions = @q3.next_questions
			q4_next_questions = @q4.next_questions
			q5_next_questions = @q5.next_questions
			q6_next_questions = @q6.next_questions

			expect(q1_next_questions.length).to eq(4)
			expect(q2_next_questions.length).to eq(2)
			expect(q3_next_questions.length).to eq(1)
			expect(q4_next_questions.length).to eq(0)
			expect(q5_next_questions.length).to eq(1)
			expect(q6_next_questions.length).to eq(1)
		end
	end

	describe "#build_answer" do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.new()
			@q = ActiveRecordSurvey::Node::Question.new(:text => "Q")
			@a1 = ActiveRecordSurvey::Node::Answer.new(:text => "A1")
			@a2 = ActiveRecordSurvey::Node::Answer.new(:text => "A2")
		end

		describe 'when invalid' do
			it 'should raise ArgumentError if survey not linked to question' do
				expect{@q.build_answer(@a1)}.to raise_error(ArgumentError)
			end
			it 'should raise ArgumentError if answers of different types added' do
				@q.survey = @survey
				a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "A1")
				a2 = ActiveRecordSurvey::Node::Answer::Text.new(:text => "A2")
				@q.build_answer(a1)
				expect{@q.build_answer(a2)}.to raise_error(ArgumentError)
			end
		end

		describe 'when valid' do
			before(:each) do
				@q.survey = @survey
			end
			it 'should return true if successful' do
				expect(@q.build_answer(@a1)).to eq(true)
			end
			it 'should link the question to the answer' do
				expect(@q.answers.length).to eq(0)
				@q.build_answer(@a1)
				expect(@q.answers.length).to eq(1)
				expect(@q.answers.first).to eq(@a1)

				expect(@survey.node_maps.length).to eq(2)
			end
			it 'should work for multiple answers' do
				expect(@q.answers.length).to eq(0)

				@q.build_answer(@a1)
				expect(@q.answers.length).to eq(1)
				expect(@q.answers.first).to eq(@a1)

				@q.build_answer(@a2)
				expect(@q.answers.length).to eq(2)
				expect(@q.answers.last).to eq(@a2)

				expect(@survey.node_maps.length).to eq(3)
			end
		end
	end

	describe 'a survey' do
		before(:all) do
			@survey = ActiveRecordSurvey::Survey.new()

			@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)

			@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
			@q2.build_answer(@q2_a1)
			@q2.build_answer(@q2_a2)

			@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3", :survey => @survey)
			@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #1")
			@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #2")
			@q3.build_answer(@q3_a1)
			@q3.build_answer(@q3_a2)

			@q4 = ActiveRecordSurvey::Node::Question.new(:text => "Question #4", :survey => @survey)
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

		describe '#answers' do
			it 'should return all the answers' do
				answers = @survey.questions.collect { |question|
					question.answers
				}.flatten

				expect(answers.length).to eq(9)
			end
		end

		describe '#build_answer' do
			it 'should have the right number of node maps' do
				@survey = ActiveRecordSurvey::Survey.new()

				@q1 = ActiveRecordSurvey::Node::Question.new(:text => "Question #1", :survey => @survey)
				@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #1")
				@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #2")
				@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #3")
				@q1.build_answer(@q1_a1)
				@q1.build_answer(@q1_a2)
				@q1.build_answer(@q1_a3)

				@q2 = ActiveRecordSurvey::Node::Question.new(:text => "Question #2", :survey => @survey)
				@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #1")
				@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 Answer #2")
				@q2.build_answer(@q2_a1)
				@q2.build_answer(@q2_a2)

				@q3 = ActiveRecordSurvey::Node::Question.new(:text => "Question #3", :survey => @survey)
				@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #1")
				@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 Answer #2")
				@q3.build_answer(@q3_a1)
				@q3.build_answer(@q3_a2)

				@q4 = ActiveRecordSurvey::Node::Question.new(:text => "Question #4", :survey => @survey)
				@q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #1")
				@q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 Answer #2")
				@q4.build_answer(@q4_a1)
				@q4.build_answer(@q4_a2)

				expect(@survey.node_maps.length).to eq(13)

				# Link up Q1
				@q1_a1.build_link(@q2)
				@q1_a2.build_link(@q3)
				@q1_a3.build_link(@q4)

				expect(@survey.node_maps.length).to eq(13)

				# Link up Q2
				@q2_a1.build_link(@q4)
				@q2_a2.build_link(@q3)

				expect(@survey.node_maps.length).to eq(19)

				# Link up Q3
				@q3_a1.build_link(@q4)
				@q3_a2.build_link(@q4)

				expect(@survey.node_maps.length).to eq(31)

				@q5 = ActiveRecordSurvey::Node::Question.new(:text => "Question #5", :survey => @survey)
				@q5_a1 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #1")
				@q5_a2 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #2")
				@q5_a3 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #3")
				@q5_a4 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #4")
				@q5_a5 = ActiveRecordSurvey::Node::Answer::Boolean.new(:text => "Q5 Answer #5")
				# Boolean builds the links differently! - it chains them so there is no branching choice
				@q5.build_answer(@q5_a1)
				@q5.build_answer(@q5_a2)
				@q5.build_answer(@q5_a3)
				@q5.build_answer(@q5_a4)
				@q5.build_answer(@q5_a5)

				@q4_a1.build_link(@q5)

				expect(@survey.node_maps.length).to eq(67)

				# Now - add an extra answer to Q1
				@q1_a4 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 Answer #4", :survey => @survey)
				@q1.build_answer(@q1_a4)

				expect(@survey.node_maps.length).to eq(68)

				@q1_a4.build_link(@q5)

				expect(@survey.node_maps.length).to eq(74)

				expect(@survey.as_map.as_json).to eq([{"text"=>"Question #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q1 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q2 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q2 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q1 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}]}])

				# Cannot build a link when a link already exists
				expect { @q1_a2.build_link(@q2) }.to raise_error RuntimeError

				# Remove the link
				@q1_a2.remove_link

				expect(@survey.as_map.as_json).to eq([{"text"=>"Question #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q1 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q2 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q2 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}, {"text"=>"Q1 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q1 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}]}, {"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}])

				@q1_a2.build_link(@q3)

				expect(@survey.as_map.as_json).to eq([{"text"=>"Question #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q1 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q2 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q2 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q1 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q3 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q3 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}]}]}, {"text"=>"Q1 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q4 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}, {"text"=>"Q4 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[]}]}]}, {"text"=>"Q1 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer", "children"=>[{"text"=>"Question #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Question", "children"=>[{"text"=>"Q5 Answer #1", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #2", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #3", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #4", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[{"text"=>"Q5 Answer #5", "id"=>nil, "node_id"=>nil, "type"=>"ActiveRecordSurvey::Node::Answer::Boolean", "children"=>[]}]}]}]}]}]}]}]}])
			end
		end
	end
end
