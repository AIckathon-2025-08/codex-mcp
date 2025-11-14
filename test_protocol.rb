require 'oj'
require 'net/http'

BASE_URL = 'http://127.0.0.1:3001/rpc'

def call_tool(method, params = {})
  uri = URI(BASE_URL)
  request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  request.body = Oj.dump({
    jsonrpc: '2.0',
    method: method,
    params: params,
    id: rand(1000)
  })

  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  Oj.load(response.body, symbol_keys: true)
end

def print_result(test_name, response)
  puts "\n#{test_name}"
  puts "=" * 60

  if response[:error]
    puts "❌ ERROR: #{response[:error][:message]}"
    puts "   Data: #{response[:error][:data]}" if response[:error][:data]
  elsif response[:result]
    result = response[:result]

    # Print based on what's in the result
    if result[:error]
      puts "❌ ERROR: #{result[:error]}"
      puts "   Message: #{result[:message]}" if result[:message]
    else
      puts "✅ SUCCESS"

      # Print interesting fields
      puts "   Task ID: #{result[:task_id]}" if result[:task_id]
      puts "   Status: #{result[:status]}" if result[:status]
      puts "   Message: #{result[:message]}" if result[:message]
      puts "   Next Step: #{result[:next_step]}" if result[:next_step]
      puts "   XP Awarded: +#{result[:xp_awarded]}" if result[:xp_awarded]
      puts "   Level: #{result.dig(:user_stats, :level)}" if result.dig(:user_stats, :level)
      puts "   Progress: #{result.dig(:quest_progress, :progress)}" if result.dig(:quest_progress, :progress)

      # Print narrator info
      if result[:narrator] && result[:narrator][:enabled]
        puts "   Narrator: ✓ Enabled"
        puts "     Voice: #{result[:narrator][:prompt][0..50]}..."
      end
    end
  end
end

puts "🧪 Testing Protocol Enhancements..."
puts "=" * 60

# Create test user
require_relative 'config/database'
require_relative 'models/user'
require_relative 'models/task'
require_relative 'models/subtask'

user = User.find_or_create_by(username: 'protocol_test_user')
puts "\n✓ Test user created (ID: #{user.id})"

# Test 1: Start quest with enhanced response
response = call_tool('start_quest_conversation', {
  user_id: user.id,
  title: "Implement user authentication"
})
print_result("1️⃣ Start Quest (Enhanced Response)", response)
task_id = response.dig(:result, :task_id)

# Test 2: Finalize quest
response = call_tool('finalize_quest', {
  task_id: task_id,
  context: "Need JWT-based auth with refresh tokens",
  objectives: [
    "Design authentication schema",
    "Implement JWT token generation",
    "Add refresh token logic",
    "Create login endpoint",
    "Create signup endpoint"
  ]
})
print_result("2️⃣ Finalize Quest (Enhanced Response)", response)

# Test 3: Mark objective complete with enhanced response
response = call_tool('mark_objective_complete', {
  task_id: task_id,
  objective_title: "Design authentication schema"
})
print_result("3️⃣ Mark Objective Complete (Enhanced Response)", response)

# Test 4: Get quest details with enhanced formatting
response = call_tool('get_quest_details', {
  task_id: task_id
})
print_result("4️⃣ Get Quest Details (Enhanced Response)", response)

# Test 5: Validation - Missing user_id
response = call_tool('start_quest_conversation', {
  title: "Test quest"
})
print_result("5️⃣ Validation Test: Missing user_id", response)

# Test 6: Validation - Too few objectives
response = call_tool('finalize_quest', {
  task_id: task_id + 1000, # Non-existent task
  context: "Test",
  objectives: ["Only one", "Only two", "Only three"]
})
print_result("6️⃣ Validation Test: Too few objectives", response)

# Test 7: List active quests with enhanced response
response = call_tool('list_active_quests', {
  user_id: user.id
})
print_result("7️⃣ List Active Quests (Enhanced Response)", response)

puts "\n" + "=" * 60
puts "✅ Protocol enhancement tests complete!"
puts "=" * 60
