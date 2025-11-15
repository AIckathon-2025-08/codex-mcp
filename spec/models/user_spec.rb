require 'spec_helper'

RSpec.describe User do
  describe '.default_user' do
    it 'creates a default user on first call' do
      expect(User.count).to eq(0)
      user = User.default_user
      expect(user).to be_persisted
      expect(user.username).to eq('default')
      expect(user.level).to eq(1)
      expect(user.xp).to eq(0)
    end

    it 'returns the same user on subsequent calls' do
      user1 = User.default_user
      user2 = User.default_user
      expect(user1.id).to eq(user2.id)
    end
  end

  describe '#award_xp' do
    let(:user) { User.create(username: 'test_user') }

    it 'awards XP to user' do
      expect { user.award_xp(50) }.to change { user.xp }.by(50)
    end

    it 'levels up at 100 XP' do
      expect { user.award_xp(100) }.to change { user.level }.from(1).to(2)
    end

    it 'levels up multiple times with enough XP' do
      user.award_xp(150)
      expect(user.level).to eq(2)
      expect(user.xp).to eq(150)
    end
  end

  describe '#stats' do
    let(:user) { User.create(username: 'test_user') }

    before do
      task1 = user.tasks.create(title: 'Task 1', status: 'active')
      task2 = user.tasks.create(title: 'Task 2', status: 'completed')
    end

    it 'returns user statistics' do
      stats = user.stats
      expect(stats[:username]).to eq('test_user')
      expect(stats[:level]).to eq(1)
      expect(stats[:xp]).to eq(0)
      expect(stats[:total_quests]).to eq(2)
      expect(stats[:active_quests]).to eq(1)
      expect(stats[:completed_quests]).to eq(1)
    end
  end
end
