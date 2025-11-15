require 'spec_helper'

RSpec.describe UserTools do
  let!(:user) { User.default_user }

  describe '.set_narrator_voice' do
    it 'sets narrator voice for default user' do
      result = UserTools.set_narrator_voice(
        narrator_prompt: 'You are GLaDOS from Portal. Be sarcastic.'
      )

      expect(result[:success]).to be true
      user.reload
      expect(user.narrator_prompt).to eq('You are GLaDOS from Portal. Be sarcastic.')
    end

    it 'returns error for missing narrator_prompt' do
      result = UserTools.set_narrator_voice({})
      expect(result[:error]).to be_present
    end
  end

  describe '.check_progress' do
    before do
      user.award_xp(50)
      user.tasks.create(title: 'Active quest', status: 'active')
      user.tasks.create(title: 'Completed quest', status: 'completed')
    end

    it 'returns user progress statistics' do
      result = UserTools.check_progress({})

      expect(result[:username]).to eq('default')
      expect(result[:level]).to eq(1)
      expect(result[:xp]).to eq(50)
      expect(result[:xp_to_next_level]).to eq(50)
      expect(result[:total_quests]).to eq(2)
      expect(result[:active_quests]).to eq(1)
      expect(result[:completed_quests]).to eq(1)
    end

    it 'includes narrator information if set' do
      user.update(narrator_prompt: 'You are a wizard')
      result = UserTools.check_progress({})

      expect(result[:narrator][:enabled]).to be true
      expect(result[:narrator][:prompt]).to eq('You are a wizard')
    end
  end
end
