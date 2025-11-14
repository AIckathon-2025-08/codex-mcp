class XPCalculator
  # Base XP per subtask completion
  BASE_SUBTASK_XP = 25

  # Bonus XP for completing entire quest
  QUEST_COMPLETION_BONUS = 100

  def self.calculate_subtask_xp(subtask)
    # Award base XP for completing a subtask
    BASE_SUBTASK_XP
  end

  def self.calculate_quest_completion_bonus(task)
    # Bonus XP based on number of subtasks
    subtask_count = task.subtasks.count

    # More subtasks = more bonus
    # 5 subtasks = 100 XP, 10 subtasks = 150 XP
    base_bonus = QUEST_COMPLETION_BONUS
    complexity_bonus = (subtask_count - 5) * 10

    [base_bonus + complexity_bonus, base_bonus].max
  end
end
