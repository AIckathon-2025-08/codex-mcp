require_relative '../config/database'
require_relative '../models/user'
require_relative '../models/task'
require_relative '../models/subtask'
require_relative '../lib/xp_calculator'
require_relative '../lib/response_helper'
require_relative '../lib/validators'
require_relative '../lib/tools/quest_tools'
require_relative '../lib/tools/progress_tools'
require_relative '../lib/tools/user_tools'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = false

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed

  # Use in-memory database for tests
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )

    # Create schema
    ActiveRecord::Schema.define do
      create_table :users, force: true do |t|
        t.string :username, null: false
        t.integer :xp, default: 0
        t.integer :level, default: 1
        t.string :narrator_prompt
        t.timestamps
      end

      create_table :tasks, force: true do |t|
        t.references :user, null: false, foreign_key: true
        t.string :title, null: false
        t.text :context
        t.string :status, default: 'gathering_context'
        t.timestamps
      end

      create_table :subtasks, force: true do |t|
        t.references :task, null: false, foreign_key: true
        t.string :title, null: false
        t.string :status, default: 'pending'
        t.integer :position
        t.integer :xp_awarded, default: 0
        t.timestamps
      end

      add_index :users, :username, unique: true
      add_index :tasks, [:user_id, :status]
      add_index :subtasks, [:task_id, :status]
    end
  end

  # Wrap each test in a transaction that rolls back
  config.around(:each) do |example|
    # Clear the default_user cache before each test
    User.instance_variable_set(:@default_user, nil)

    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
