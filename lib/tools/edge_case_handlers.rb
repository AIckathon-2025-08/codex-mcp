module EdgeCaseHandlers
  # Handle trying to complete already completed quest
  def self.handle_already_completed_quest(task)
    {
      error: "Quest already completed",
      task_id: task.id,
      completed_at: task.updated_at.iso8601,
      message: "This quest was already finished. Create a new quest with start_quest_conversation."
    }
  end

  # Handle trying to finalize already finalized quest
  def self.handle_already_finalized_quest(task)
    {
      error: "Quest already finalized",
      task_id: task.id,
      current_objectives: task.subtasks.count,
      message: "This quest already has #{task.subtasks.count} objectives. Use get_quest_details to see them."
    }
  end

  # Handle trying to mark objective complete when all are done
  def self.handle_no_pending_objectives(task)
    {
      error: "No pending objectives",
      task_id: task.id,
      progress: task.progress,
      message: "All objectives already completed. Call complete_quest to finish the quest."
    }
  end
end
