[![Gem Version](https://badge.fury.io/rb/active_record_survey.svg)](http://badge.fury.io/rb/active_record_survey)
[![Build Status](https://travis-ci.org/butchmarshall/active_record_survey.svg?branch=master)](https://travis-ci.org/butchmarshall/active_record_survey)

# ActiveRecordSurvey

An attempt at a more versatile data structure for making and taking surveys.

This gem tries to be as unopinionated as possible on the peripheral details on how you implement a survey.

The goal is to give a simple interface for creating surveys and validating the answers given to them.

Release Notes
============

**0.1.36**
 - `ActiveRecordSurvey::Node::Answer#build_link` and `ActiveRecordSurvey::Node::Answer#remove_link` moved to `ActiveRecordSurvey::Node` so that questions can directly follow one another without answers
 - Implemented `ActiveRecordSurvey::Node::Question#next_questions` to return all questions that follow either directly or through answers

**0.1.33**
 - `ActiveRecordSurvey::Node::Answer#sibling_index` method for setting position as well

**0.1.32**
 - `ActiveRecordSurvey::Node::Answer#sibling_index` for regular answers and chained answers

**0.1.31**
 - `ActiveRecordSurvey::Node::Answer#move_up` and `ActiveRecordSurvey::Node::Answer#move_down` implemented so you can change the position of answers relative to one another i both branching and chained types.
	I am not happy yet with this.  [AwesomeNestedSet](https://github.com/collectiveidea/awesome_nested_set) seems to require nodes exist before moving them which is a limitation I'd like to not have.

**0.1.30**
 - `ActiveRecordSurvey::Node::Question` now throws ArgumentError if answers of different types are added to it

**0.1.29**
 - `ActiveRecordSurvey::Node::Answer` now cleans up associated node_maps on destruction
 - extending/including `ActiveRecordSurvey::Answer::Chained` now rebuilds broken links in the parent<->child node_maps if a middle node_map is destroyed

**0.1.26**
 - Major refactor of answer#build_link and answer#remove_link
 - `ActiveRecordSurvey::Node` now has a direct reference to its survey.  Don't forget to run the install task Update_0_1_26_ActiveRecordSurvey
 - survey#build_question removed, no longer needed, just use survey.questions.build

**0.1.24**
 - Refactored class `ActiveRecordSurvey::Node::Answer::Chain` to module `ActiveRecordSurvey::Node::Answer::Chained` - this functionality makes way more sense implemented as a module.

**0.1.23**
 - Added `ActiveRecordSurvey::Node::Answer::Chain` for common chainable interface for answers

**0.1.22**
 - answer#remove_link cleaned up so it can be understood

**0.1.21**
 - answer#build_link now detects and throws an error when a infinite loop is added

**0.1.20**
 - answer#remove_link wasn't correct.  Fixed and added unit tests

**0.1.15**
 - Don't consider instance_nodes marked for destruction when validating

**0.1.14**
 - build_question now only accepts a question
 - Exceptions added

**0.1.13**
 - Added Question#build_answer and Answer#build_link to make survey creation possible without dealing with internal nodes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_survey'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_survey

## Installation

```ruby
rails generate active_record_survey:active_record
```

## Usage

See the spec file for more detailed usage.

***Please*** be aware that the default gem does not prescribe how your `ActiveRecordSurvey::Node` should store text - that's up for you to implement.

See the spec for a sample implementation or [ActiveRecordSurveyApi](https://github.com/butchmarshall/active_record_survey_api) for a fully translatable implementation using the [Globalize](https://github.com/globalize/globalize) gem.

The usage below with `:text => ""` will not actually work unless you implement `:text`

### Build a basic survey
```ruby

# Building surveys
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

# Commit everything to the database!
@survey.save
```

The will build a survey with the following node structure.

![alt tag](https://raw.githubusercontent.com/butchmarshall/active_record_survey/master/bin/Example_1.png)

### Answer Types

A number of different answer types are implemented by default.

 - [Default (a.k.a radio)](#answer_default)
 - [Boolean (a.k.a. checkbox)](#answer_checkbox)
 - [Rank](#answer_rank)
 - [Scale](#answer_scale)
 - [Text](#answer_text)

<a id="answer_default"></a>
#### Default 

```ruby
ActiveRecordSurvey::Node::Answer
```

The default answer type (think of it like a radio question) - this is currently the only answer type you can attach to a question so that depending on the answer given you can branch to a different question.

<a id="answer_checkbox"></a>
#### Boolean

```ruby
ActiveRecordSurvey::Node::Answer::Boolean
```

True/False (0/1 actually... think of it like a checkbox) answer types.

<a id="answer_rank"></a>
#### Rank

```ruby
ActiveRecordSurvey::Node::Answer::Rank
```

Rankable (answer value is 1..NUM_ANSWERS) to rank the answers in relation to one another.

<a id="answer_scale"></a>
#### Scale

```ruby
ActiveRecordSurvey::Node::Answer::Scale
```

Scale (answer value is a min/max on a scale of A->B) where you can specificy each answer on a scale

<a id="answer_text"></a>
#### Text

```ruby
ActiveRecordSurvey::Node::Answer::Text
```

Textual answer to a question (e.g. please tell us what you thinik...)

### Answer Validation

Enforcing answer criteria is accomplished by attaching validation nodes to `ActiveRecordSurvey::Node` records.

When a survey is taken validations are automatically run and their criteria is enforced.

A number of validations are already implemented by default.

You can implement your own validation by extending the `ActiveRecordSurvey::ValidationNode` class.

 - [MaximumAnswer](#answer_maximum_answer)
 - [MinimumAnswer](#answer_minimum_answer)
 - [MaximumValue](#answer_maximum_value)
 - [MinimumValue](#answer_minimum_value)
 - [MaximumLength](#answer_maximum_length)
 - [MinimumLength](#answer_minimum_length)

<a id="answer_maximum_answer"></a>
#### MaximumAnswer

```ruby
ActiveRecordSurvey::ValidationNode::MaximumAnswer
```

These nodes should only be attached to nodes which extend `ActiveRecordSurvey::Node::Question` nodes.

Ensures that a maximum numer of answers have been selected.  For chained answer nodes such as `ActiveRecordSurvey::Node::Answer::Boolean`,`ActiveRecordSurvey::Node::Answer::Rank`, and `ActiveRecordSurvey::Node::Answer::Scale` it enforces a maximum amount that be answered.

<a id=answer_minimum_answer""></a>
#### MinimumAnswer

```ruby
ActiveRecordSurvey::ValidationNode::MinimumAnswer
```

These nodes should only be attached to nodes which extend `ActiveRecordSurvey::Node::Question` nodes.

Ensures that a minimum numer of answers have been selected.  For chained answer nodes such as `ActiveRecordSurvey::Node::Answer::Boolean`,`ActiveRecordSurvey::Node::Answer::Rank`, and `ActiveRecordSurvey::Node::Answer::Scale` it enforces a minimum amount that can be answered.

<a id="answer_maximum_value"></a>
#### MaximumValue

```ruby
ActiveRecordSurvey::ValidationNode::MaximumValue
```

These nodes should only be attached to nodes which extend `ActiveRecordSurvey::Node::Answer` nodes which record an scalar answer value such as  `ActiveRecordSurvey::Node::Answer::Scale`.

Ensures that a minimum scalar value has been entered.

<a id="answer_minimum_value"></a>
#### MinimumValue

```ruby
ActiveRecordSurvey::ValidationNode::MinimumValue
```

These nodes should only be attached to nodes which extend `ActiveRecordSurvey::Node::Answer` nodes which record an scalar answer value such as  `ActiveRecordSurvey::Node::Answer::Scale`.

Ensures that a maximum scalar value has been entered.

<a id="answer_maximum_length"></a>
#### MaximumLength

```ruby
ActiveRecordSurvey::ValidationNode::MaximumLength
```

These nodes should only be attached to nodes which extend `ActiveRecordSurvey::Node::Answer` nodes nodes which record a text value such as `ActiveRecordSurvey::Node::Answer::Text`.

Ensures that a maximum amount of text has been answered.

<a id="answer_minimum_length"></a>
#### MinimumLength

```ruby
ActiveRecordSurvey::ValidationNode::MinimumLength
```

These nodes should only be attached to nodes which extend `ActiveRecordSurvey::Node::Answer` nodes nodes which record a text value such as `ActiveRecordSurvey::Node::Answer::Text`.

Ensures that a minimum amount of text has been answered.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/butchmarshall/active_record_survey.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

