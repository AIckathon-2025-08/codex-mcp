require 'spec_helper'

RSpec.describe Subtask do
  let(:user) { User.create(username: 'test_user') }
  let(:task) { user.tasks.create(title: 'Test task', status: 'active') }
  let(:subtask) { task.subtasks.create(title: 'Test subtask') }

  describe 'creation' do
    it 'creates a valid subtask' do
      expect(subtask).to be_persisted
      expect(subtask.title).to eq('Test subtask')
      expect(subtask.status).to eq('pending')
    end

    it 'belongs to a task' do
      expect(subtask.task).to eq(task)
    end
  end

  describe '#complete!' do
    it 'marks subtask as completed' do
      expect { subtask.complete! }.to change { subtask.status }.from('pending').to('completed')
    end

    it 'sets completion timestamp' do
      subtask.complete!
      expect(subtask.updated_at).to be_present
    end
  end
end
