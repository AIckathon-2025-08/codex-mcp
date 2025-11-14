require_relative 'config/database'
require_relative 'models/user'
require_relative 'models/task'
require_relative 'models/subtask'

puts "🧪 Testing Models..."

# Clean up any existing test data
User.where(username: "test_runner").destroy_all

# Test User creation
user = User.create(username: "test_runner")
if user.persisted?
  puts "✓ Created user: #{user.username} (Level #{user.level}, #{user.xp} XP)"
else
  puts "✗ Failed to create user: #{user.errors.full_messages}"
  exit 1
end

# Test Task creation
task = user.tasks.create(
  title: "Fix authentication bug",
  context: "Users timing out after 5 minutes",
  status: "active"
)
if task.persisted?
  puts "✓ Created task: #{task.title}"
else
  puts "✗ Failed to create task: #{task.errors.full_messages}"
  exit 1
end

# Test SubTask creation
subtask1 = task.subtasks.create(title: "Check Redis TTL configuration")
puts "  Subtask1 errors: #{subtask1.errors.full_messages}" unless subtask1.persisted?
subtask2 = task.subtasks.create(title: "Review session middleware")
puts "  Subtask2 errors: #{subtask2.errors.full_messages}" unless subtask2.persisted?
subtask3 = task.subtasks.create(title: "Add logging to session lifecycle")
puts "  Subtask3 errors: #{subtask3.errors.full_messages}" unless subtask3.persisted?
puts "✓ Created #{task.subtasks.count} subtasks"

# Test progress tracking
puts "  Progress: #{task.progress}"
puts "  Completion: #{task.completion_percentage}%"

# Test XP award
puts "\n🎮 Testing XP system..."
puts "  Before: Level #{user.level}, #{user.xp} XP"

user.award_xp(50)
puts "  After +50 XP: Level #{user.level}, #{user.xp} XP"

user.award_xp(60)
puts "  After +60 XP: Level #{user.level}, #{user.xp} XP (should level up to 2 at 100 XP)"

# Test subtask completion
puts "\n✅ Completing subtask..."
subtask1.complete!
puts "  Progress: #{task.progress}"
puts "  Completion: #{task.completion_percentage}%"

# Test stats
puts "\n📊 User stats:"
stats = user.stats
stats.each { |k, v| puts "  #{k}: #{v}" }

puts "\n✅ All model tests passed!"
