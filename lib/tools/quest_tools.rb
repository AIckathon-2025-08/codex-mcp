require_relative '../xp_calculator'
require_relative '../response_helper'
require_relative '../validators'
require_relative 'edge_case_handlers'

class QuestTools
  # Start a new quest conversation
  # Returns clarifying questions for Claude to ask the user
  def self.start_quest_conversation(params)
    # Get the default user
    user = User.default_user

    # Validate title
    title_result = Validators.validate_title(params[:title])
    return title_result if title_result[:error]

    # Create task in 'planning' status
    task = user.tasks.create!(
      title: params[:title],
      status: 'planning'
    )

    # Return questions and instructions for Claude
    {
      task_id: task.id,
      status: 'gathering_context',
      required_questions: [
        "What are the specific symptoms or issues you're experiencing?",
        "What systems, components, or areas are involved?",
        "What's the current behavior versus what you expect?"
      ],
      next_tool: 'finalize_quest',
      instructions: "Ask these clarifying questions conversationally. Once you understand the problem, break it into 5-10 concrete technical subtasks and call finalize_quest.",
      narrator: ResponseHelper.narrator_instructions(user),
      context: {
        user_level: user.level,
        user_xp: user.xp,
        active_quests: user.active_tasks.count
      }
    }
  end

  # Finalize quest with objectives
  # Stores subtasks and activates the quest
  def self.finalize_quest(params)
    # Validate inputs
    task_result = Validators.validate_task_id(params[:task_id])
    return task_result if task_result[:error]
    task = task_result[:task]

    # Check if already finalized
    if task.subtasks.any?
      return EdgeCaseHandlers.handle_already_finalized_quest(task)
    end

    obj_result = Validators.validate_objectives(params[:objectives])
    return obj_result if obj_result[:error]

    context = params[:context] || ""
    objectives = params[:objectives]

    # Store context
    task.update!(context: context)

    # Create subtasks
    objectives.each_with_index do |objective_title, index|
      task.subtasks.create!(
        title: objective_title,
        position: index + 1
      )
    end

    # Activate task
    task.activate!

    user = task.user

    # Return quest details
    {
      task_id: task.id,
      status: 'active',
      title: task.title,
      context: task.context,
      objectives: task.subtasks.ordered.map { |st|
        {
          id: st.id,
          title: st.title,
          status: st.status,
          position: st.position
        }
      },
      progress: task.progress,
      completion_percentage: 0,
      next_step: ResponseHelper.generate_next_step_instruction(task, user),
      narrator: ResponseHelper.narrator_instructions(user),
      message: "Quest activated with #{task.subtasks.count} objectives. User can now work on these tasks and report progress."
    }
  end

  # Complete entire quest
  # Awards bonus XP and marks quest as done
  def self.complete_quest(params)
    # Validate inputs
    task_result = Validators.validate_task_id(params[:task_id])
    return task_result if task_result[:error]
    task = task_result[:task]

    # Check if already completed
    if task.status == 'completed'
      return EdgeCaseHandlers.handle_already_completed_quest(task)
    end

    # Check if all objectives are complete
    unless task.all_objectives_complete?
      pending = task.subtasks.pending.count
      return { error: "Cannot complete quest: #{pending} objectives still pending" }
    end

    # Award bonus XP
    bonus_xp = XPCalculator.calculate_quest_completion_bonus(task)
    previous_level = task.user.level
    task.user.award_xp(bonus_xp)
    leveled_up = task.user.level > previous_level

    # Mark quest complete
    task.complete!

    {
      success: true,
      task_id: task.id,
      status: 'completed',
      celebration: ResponseHelper.celebration_data(task, bonus_xp, leveled_up, task.user),
      stats: {
        total_xp: task.user.xp,
        level: task.user.level,
        xp_to_next_level: task.user.stats[:xp_to_next_level],
        completed_quests: task.user.completed_tasks.count
      }
    }
  end
end
