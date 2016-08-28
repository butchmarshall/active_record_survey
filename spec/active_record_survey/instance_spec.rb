require 'spec_helper'

describe ActiveRecordSurvey::Instance, :instance_spec => true do
	before(:each) do
		@survey = FactoryGirl.build(:boolean_survey)
		@survey.save

		@survey.questions.each { |q|
			@q1 = q if q.text == "Q1"
			@q2 = q if q.text == "Q2"
			@q3 = q if q.text == "Q3"
			@q4 = q if q.text == "Q4"
			@q5 = q if q.text == "Q5"
		}
		
		@q1.answers.each { |a|
			@q1_a1 = a if a.text == "Q1 A1"
			@q1_a2 = a if a.text == "Q1 A2"
		}
		@q2.answers.each { |a|
			@q2_a1 = a if a.text == "Q2 A1"
			@q2_a2 = a if a.text == "Q2 A2"
		}
		@q3.answers.each { |a|
			@q3_a1 = a if a.text == "Q3 A1"
			@q3_a2 = a if a.text == "Q3 A2"
		}
		@q4.answers.each { |a|
			@q4_a1 = a if a.text == "Q4 A1"
			@q4_a2 = a if a.text == "Q4 A2"
		}
		@instance = ActiveRecordSurvey::Instance.new(:survey => @survey)
	end

	describe "#invalid?" do
		it 'should not allow not starting from the root' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q3_a1)

			expect(@instance.invalid?).to eq(true)
		end

		it 'should not allow impossible answers' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q1_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q3_a1)

			expect(@instance.invalid?).to eq(true)
		end

		it 'should fail when boolean answer is not passed an value of [0,1]' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q1_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a2)

			expect(@instance.invalid?).to eq(true)
		end

		it 'should allow an incompleted survey, even if a missing part is a question node only' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q1_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a1, :value => 1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a2, :value => 0)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q3_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q5)

			expect(@instance.invalid?).to eq(true)
		end
	end

	describe "#valid?" do
		it 'should allow a single answer' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q1_a1)

			expect(@instance.valid?).to eq(true)
		end

		it 'should allow multiple answers' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q1_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a1, :value => 0)

			expect(@instance.valid?).to eq(true)
		end

		it 'should allow a completed survey' do
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q1_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a1, :value => 1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q2_a2, :value => 0)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q3_a1)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q4)
			@instance.instance_nodes << ActiveRecordSurvey::InstanceNode.new(:instance => @instance, :node => @q5)

			expect(@instance.valid?).to eq(true)
		end
	end
end