require_relative '../validators'
require_relative '../response_helper'

class UserTools
  # Set narrator voice
  def self.set_narrator_voice(params)
    # Get the default user
    user = User.default_user

    narrator_prompt = params[:narrator_prompt]
    return { error: "narrator_prompt is required" } if narrator_prompt.nil? || narrator_prompt.empty?

    user.update!(narrator_prompt: narrator_prompt)

    {
      success: true,
      user_id: user.id,
      narrator_prompt: user.narrator_prompt,
      message: "Narrator voice updated successfully",
      instruction: "Use this narrator voice when presenting quests, progress, and achievements to the user."
    }
  end

  # Check user progress/stats
  def self.check_progress(params)
    # Get the default user
    user = User.default_user

    {
      user_id: user.id,
      username: user.username,
      level: user.level,
      xp: user.xp,
      xp_to_next_level: user.stats[:xp_to_next_level],
      total_quests: user.tasks.count,
      active_quests: user.active_tasks.count,
      completed_quests: user.completed_tasks.count,
      narrator: ResponseHelper.narrator_instructions(user),
      message: user.active_tasks.any? ?
        "User has #{user.active_tasks.count} active quest(s). Check which ones need attention." :
        "No active quests. Ready to start a new quest!"
    }
  end
end
