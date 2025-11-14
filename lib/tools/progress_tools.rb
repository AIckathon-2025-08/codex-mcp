require_relative '../xp_calculator'
require_relative '../response_helper'
require_relative '../validators'
require_relative 'edge_case_handlers'

class ProgressTools
  # Mark a specific objective as complete
  def self.mark_objective_complete(params)
    # Validate inputs
    task_result = Validators.validate_task_id(params[:task_id])
    return task_result if task_result[:error]
    task = task_result[:task]

    objective_title = params[:objective_title]
    return { error: "objective_title is required" } if objective_title.nil? || objective_title.empty?

    # Check if all objectives already complete
    if task.all_objectives_complete?
      return EdgeCaseHandlers.handle_no_pending_objectives(task)
    end

    # Find subtask by partial or exact title match
    subtask = task.subtasks.pending.find do |st|
      st.title.downcase.include?(objective_title.downcase) ||
      objective_title.downcase.include?(st.title.downcase)
    end

    return { error: "Objective not found or already completed" } unless subtask

    # Mark complete
    subtask.complete!

    # Award XP
    xp_earned = XPCalculator.calculate_subtask_xp(subtask)
    previous_level = task.user.level
    task.user.award_xp(xp_earned)
    leveled_up = task.user.level > previous_level

    {
      success: true,
      objective: {
        id: subtask.id,
        title: subtask.title,
        status: 'completed',
        position: subtask.position
      },
      xp_awarded: xp_earned,
      level_up: leveled_up,
      user_stats: {
        xp: task.user.xp,
        level: task.user.level,
        xp_to_next_level: task.user.stats[:xp_to_next_level]
      },
      quest_progress: {
        progress: task.progress,
        completion_percentage: task.completion_percentage,
        all_complete: task.all_objectives_complete?
      },
      next_step: ResponseHelper.generate_next_step_instruction(task, task.user),
      message: leveled_up ?
        "Objective complete! User leveled up to #{task.user.level}!" :
        "Objective complete. #{task.subtasks.pending.count} remaining."
    }
  end

  # Get quest details
  def self.get_quest_details(params)
    # Validate inputs
    task_result = Validators.validate_task_id(params[:task_id])
    return task_result if task_result[:error]
    task = task_result[:task]

    {
      quest: {
        id: task.id,
        title: task.title,
        context: task.context,
        status: task.status,
        progress: task.progress,
        completion_percentage: task.completion_percentage,
        created_at: task.created_at.iso8601
      },
      objectives: task.subtasks.ordered.map { |st|
        {
          id: st.id,
          title: st.title,
          status: st.status,
          position: st.position,
          icon: st.status == 'completed' ? '✓' : '☐'
        }
      },
      user: {
        username: task.user.username,
        level: task.user.level,
        xp: task.user.xp
      },
      next_step: ResponseHelper.generate_next_step_instruction(task, task.user)
    }
  end

  # List active quests
  def self.list_active_quests(params)
    # Get the default user
    user = User.default_user

    active_tasks_data = user.active_tasks.map do |task|
      pending_objectives = task.subtasks.pending.pluck(:title)

      {
        task_id: task.id,
        title: task.title,
        status: task.status,
        progress: task.progress,
        completion_percentage: task.completion_percentage,
        objective_count: task.subtasks.count,
        completed_count: task.subtasks.completed.count,
        next_objective: pending_objectives.first,
        created_at: task.created_at.iso8601
      }
    end

    {
      user_id: user.id,
      username: user.username,
      active_quests: active_tasks_data,
      count: active_tasks_data.length,
      message: active_tasks_data.any? ?
        "User has #{active_tasks_data.length} active quest(s). Ask which one they want to work on." :
        "No active quests. Suggest starting a new quest with start_quest_conversation.",
      narrator: ResponseHelper.narrator_instructions(user)
    }
  end
end
