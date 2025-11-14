module ResponseHelper
  # Generate contextual instructions based on task state
  def self.generate_next_step_instruction(task, user)
    case task.status
    when 'planning'
      "The quest is in planning phase. Ask clarifying questions, then call finalize_quest with 5-10 objectives."
    when 'active'
      if task.all_objectives_complete?
        "All objectives complete! Call complete_quest(task_id: #{task.id}) to finish and award bonus XP."
      else
        completed = task.subtasks.completed.count
        total = task.subtasks.count
        remaining = task.subtasks.pending.pluck(:title)

        "Quest in progress (#{completed}/#{total}). #{remaining.length} objectives remaining: #{remaining.first(3).join(', ')}#{remaining.length > 3 ? '...' : ''}. Mark objectives complete as the user finishes them."
      end
    when 'completed'
      "Quest completed! #{task.subtasks.count} objectives finished. Check if the user wants to start a new quest."
    end
  end

  # Format narrator instructions
  def self.narrator_instructions(user)
    if user.narrator_prompt.present?
      {
        enabled: true,
        prompt: user.narrator_prompt,
        instruction: "Use this narrator voice when presenting information to the user. Stay in character."
      }
    else
      {
        enabled: false,
        instruction: "No narrator voice set. Present information neutrally, or suggest the user can customize their narrator with set_narrator_voice."
      }
    end
  end

  # Generate celebration message data
  def self.celebration_data(task, xp_awarded, leveled_up, user)
    {
      quest_title: task.title,
      objectives_completed: task.subtasks.count,
      xp_awarded: xp_awarded,
      total_xp: user.xp,
      level: user.level,
      leveled_up: leveled_up,
      suggestion: leveled_up ?
        "Level up! The user just reached level #{user.level}. Celebrate this achievement!" :
        "Quest complete. Acknowledge the completion and offer to start a new quest.",
      narrator: narrator_instructions(user)
    }
  end
end
