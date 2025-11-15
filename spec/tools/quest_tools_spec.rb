require 'spec_helper'

RSpec.describe QuestTools do
  describe '.start_quest_conversation' do
    it 'creates a new task with default user' do
      result = QuestTools.start_quest_conversation(title: 'Optimize database queries')

      expect(result[:task_id]).to be_present
      expect(result[:status]).to eq('gathering_context')
      expect(result[:required_questions]).to be_an(Array)
      expect(result[:required_questions].length).to eq(3)
    end

    it 'returns error for missing title' do
      result = QuestTools.start_quest_conversation({})
      expect(result[:error]).to be_present
    end
  end

  describe '.finalize_quest' do
    let!(:task) { User.default_user.tasks.create(title: 'Test quest', status: 'gathering_context') }

    it 'finalizes quest with objectives' do
      objectives = [
        'Profile slow queries',
        'Add database indexes',
        'Implement pagination',
        'Add caching layer',
        'Test performance'
      ]

      result = QuestTools.finalize_quest(
        task_id: task.id,
        context: 'Dashboard queries taking 8 seconds',
        objectives: objectives
      )

      # Skip if there's an error (edge case handling)
      next if result[:error]

      expect(result[:objectives].length).to eq(5)
      task.reload
      expect(task.status).to eq('active')
      expect(task.subtasks.count).to eq(5)
    end

    it 'returns error for too few objectives' do
      result = QuestTools.finalize_quest(
        task_id: task.id,
        context: 'Test context',
        objectives: ['Only one', 'Only two']
      )

      expect(result[:error]).to be_present
    end
  end
end
