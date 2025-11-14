module Validators
  def self.validate_user_id(user_id)
    return { error: "user_id is required" } if user_id.nil?
    return { error: "user_id must be an integer" } unless user_id.is_a?(Integer)

    user = User.find_by(id: user_id)
    return { error: "User not found with id #{user_id}" } unless user

    { valid: true, user: user }
  end

  def self.validate_task_id(task_id)
    return { error: "task_id is required" } if task_id.nil?
    return { error: "task_id must be an integer" } unless task_id.is_a?(Integer)

    task = Task.find_by(id: task_id)
    return { error: "Task not found with id #{task_id}" } unless task

    { valid: true, task: task }
  end

  def self.validate_objectives(objectives)
    return { error: "objectives array is required" } if objectives.nil?
    return { error: "objectives must be an array" } unless objectives.is_a?(Array)
    return { error: "objectives cannot be empty" } if objectives.empty?
    return { error: "minimum 5 objectives required (got #{objectives.length})" } if objectives.length < 5
    return { error: "maximum 10 objectives allowed (got #{objectives.length})" } if objectives.length > 10

    # Check all are strings
    non_strings = objectives.reject { |obj| obj.is_a?(String) }
    return { error: "all objectives must be strings" } if non_strings.any?

    # Check for reasonable length
    too_long = objectives.select { |obj| obj.length > 200 }
    return { error: "objective titles must be under 200 characters" } if too_long.any?

    { valid: true }
  end

  def self.validate_title(title)
    return { error: "title is required" } if title.nil? || title.empty?
    return { error: "title must be a string" } unless title.is_a?(String)
    return { error: "title too long (max 200 characters)" } if title.length > 200

    { valid: true }
  end
end
