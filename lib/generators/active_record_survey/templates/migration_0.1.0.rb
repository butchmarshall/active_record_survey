class AddActiveRecordSurvey < ActiveRecord::Migration
	def self.up
		create_table :active_record_surveys do |t|
			t.timestamps null: false
		end

		create_table :active_record_survey_nodes do |t|
			t.string :type
			t.string :text

			t.timestamps null: false
		end

		create_table :active_record_survey_node_maps do |t|
			t.references :active_record_survey_node

			# AwesomeNestedSet fields
			t.integer :parent_id, :null => true, :index => true
			t.integer :lft, :null => false, :index => true
			t.integer :rgt, :null => false, :index => true
			t.integer :depth, :null => false, :default => 0
			t.integer :children_count, :null => false, :default => 0

			t.references :active_record_survey

			t.timestamps null: false
		end

		create_table :active_record_survey_instances do |t|
			t.references :active_record_survey

			t.timestamps null: false
		end
		create_table :active_record_survey_instance_nodes do |t|
			t.references :active_record_survey_instance
			t.references :active_record_survey_node

			t.timestamps null: false
		end
	end

	def self.down
		drop_table :active_record_survey_node_maps
	end
end