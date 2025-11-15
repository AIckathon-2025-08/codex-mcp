require 'spec_helper'

RSpec.describe Task do
  let(:user) { User.create(username: 'test_user') }
  let(:task) { user.tasks.create(title: 'Fix authentication bug', context: 'Users timing out', status: 'active') }

  describe 'creation' do
    it 'creates a valid task' do
      expect(task).to be_persisted
      expect(task.title).to eq('Fix authentication bug')
      expect(task.status).to eq('active')
    end

    it 'belongs to a user' do
      expect(task.user).to eq(user)
    end
  end

  describe '#progress' do
    before do
      task.subtasks.create(title: 'Subtask 1', status: 'completed')
      task.subtasks.create(title: 'Subtask 2', status: 'pending')
      task.subtasks.create(title: 'Subtask 3', status: 'pending')
    end

    it 'returns progress string' do
      expect(task.progress).to eq('1/3')
    end
  end

  describe '#completion_percentage' do
    before do
      task.subtasks.create(title: 'Subtask 1', status: 'completed')
      task.subtasks.create(title: 'Subtask 2', status: 'completed')
      task.subtasks.create(title: 'Subtask 3', status: 'pending')
      task.subtasks.create(title: 'Subtask 4', status: 'pending')
    end

    it 'calculates completion percentage' do
      expect(task.completion_percentage).to eq(50)
    end

    it 'returns 0 for tasks with no subtasks' do
      empty_task = user.tasks.create(title: 'Empty task')
      expect(empty_task.completion_percentage).to eq(0)
    end
  end
end
