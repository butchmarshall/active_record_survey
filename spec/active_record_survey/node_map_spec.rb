require 'spec_helper'

describe ActiveRecordSurvey::NodeMap, :node_map_spec => true do
	describe '#has_infinite_loop?' do
		before(:each) do
			@survey = ActiveRecordSurvey::Survey.create()
			@q1 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Q1", :survey => @survey)
			@q1_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A1")
			@q1_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A2")
			@q1_a3 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A3")
			@q1_a4 = ActiveRecordSurvey::Node::Answer.new(:text => "Q1 A4")
			@q1.build_answer(@q1_a1)
			@q1.build_answer(@q1_a2)
			@q1.build_answer(@q1_a3)
			@q1.build_answer(@q1_a4)

			@q2 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Q2", :survey => @survey)
			@q2_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A1")
			@q2_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q2 A2")
			@q2.build_answer(@q2_a1)
			@q2.build_answer(@q2_a2)

			@q3 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Q3", :survey => @survey)
			@q3_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A1")
			@q3_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q3 A2")
			@q3.build_answer(@q3_a1)
			@q3.build_answer(@q3_a2)

			@q4 = @survey.questions.build(:type => "ActiveRecordSurvey::Node::Question", :text => "Q4", :survey => @survey)
			@q4_a1 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A1")
			@q4_a2 = ActiveRecordSurvey::Node::Answer.new(:text => "Q4 A2")
			@q4.build_answer(@q4_a1)
			@q4.build_answer(@q4_a2)

			@q1_a1.build_link(@q3)
			@q1_a2.build_link(@q4)
			@q1_a3.build_link(@q3)
			@q1_a4.build_link(@q3)

			@q2_a1.build_link(@q1)
			@q2_a2.build_link(@q4)

			@q3_a1.build_link(@q4)
			@q3_a2.build_link(@q4)
		end

		describe 'build' do
			it 'should not allow finite loop' do
				expect { @q4_a1.build_link(@q1) }.to raise_error RuntimeError
			end
		end

		describe 'save' do
			it 'should not allow finite loop' do
				@survey.save
				expect { @q4_a1.build_link(@q1) }.to raise_error RuntimeError
			end
		end
	end
end