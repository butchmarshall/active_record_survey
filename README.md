[![Gem Version](https://badge.fury.io/rb/active_record_survey.svg)](http://badge.fury.io/rb/active_record_survey)
[![Build Status](https://travis-ci.org/butchmarshall/active_record_survey.svg?branch=master)](https://travis-ci.org/butchmarshall/active_record_survey)

# ActiveRecordSurvey

An attempt at a more versatile data structure for making and taking surveys.

This gem tries to be as unopinionated as possible on the peripheral details on how you implement a survey.

The goal is to give a simple interface for creating surveys and validating the answers given to them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_survey'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_survey

## Usage

See the spec file for more detailed usage.

**Build a basic survey**
```ruby

q1 = ActiveRecordSurvey::Node::Question.new() # Q1
q1_a1 = ActiveRecordSurvey::Node::Answer.new() # Q1 A1
q1_a2 = ActiveRecordSurvey::Node::Answer.new() # Q1 A2
q1_a3 = ActiveRecordSurvey::Node::Answer.new() # Q1 A3

q2 = ActiveRecordSurvey::Node::Question.new() # Q2
q2_a1 = ActiveRecordSurvey::Node::Answer.new() # Q2 A1
q2_a2 = ActiveRecordSurvey::Node::Answer.new() # Q2 A2

q3 = ActiveRecordSurvey::Node::Question.new() # Q3
q3_a1 = ActiveRecordSurvey::Node::Answer.new() # Q3 A1
q3_a2 = ActiveRecordSurvey::Node::Answer.new() # Q3 A2

q4 = ActiveRecordSurvey::Node::Question.new() # Q4
q4_a1 = ActiveRecordSurvey::Node::Answer.new() # Q4 A1
q4_a2 = ActiveRecordSurvey::Node::Answer.new() # Q4 A2

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
```

The will build a survey with the following node structure.

![alt tag](https://raw.githubusercontent.com/butchmarshall/active_record_survey/master/bin/Example_1.png)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/butchmarshall/active_record_survey.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

