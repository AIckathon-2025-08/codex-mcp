require 'spec_helper'

RSpec.describe ProgressTools do
  let!(:user) { User.default_user }
  let!(:task) { user.tasks.create(title: 'Test quest', status: 'active', context: 'Test context') }

  before do
    task.subtasks.create(title: 'Objective 1', status: 'completed', xp_awarded: 25)
    task.subtasks.create(title: 'Objective 2', status: 'pending')
    task.subtasks.create(title: 'Objective 3', status: 'pending')
  end

  describe '.list_active_quests' do
    it 'lists active quests for default user' do
      result = ProgressTools.list_active_quests({})

      expect(result[:count]).to eq(1)
      expect(result[:active_quests].first[:title]).to eq('Test quest')
      expect(result[:active_quests].first[:progress]).to eq('1/3')
    end

    it 'returns empty list when no active quests' do
      task.update(status: 'completed')
      result = ProgressTools.list_active_quests({})

      expect(result[:count]).to eq(0)
      expect(result[:active_quests]).to be_empty
    end
  end

  describe '.mark_objective_complete' do
    it 'marks objective as complete and awards XP' do
      result = ProgressTools.mark_objective_complete(
        task_id: task.id,
        objective_title: 'Objective 2'
      )

      expect(result[:xp_awarded]).to eq(25)
      expect(result[:quest_progress][:progress]).to eq('2/3')
      task.reload
      expect(task.subtasks.where(status: 'completed').count).to eq(2)
    end

    it 'handles partial title match' do
      result = ProgressTools.mark_objective_complete(
        task_id: task.id,
        objective_title: 'Objective'
      )

      expect(result[:xp_awarded]).to eq(25)
    end
  end


  describe '.get_quest_details' do
    it 'returns detailed quest information' do
      result = ProgressTools.get_quest_details(task_id: task.id)

      expect(result[:quest][:title]).to eq('Test quest')
      expect(result[:quest][:context]).to eq('Test context')
      expect(result[:quest][:progress]).to eq('1/3')
      expect(result[:quest][:completion_percentage]).to eq(33)
      expect(result[:objectives].length).to eq(3)
    end
  end
end
