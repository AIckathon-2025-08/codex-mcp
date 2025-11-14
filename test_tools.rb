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

puts "🧪 Testing Tool Implementation..."
puts

# First, create a test user manually
require_relative 'config/database'
require_relative 'models/user'
require_relative 'models/task'
require_relative 'models/subtask'

user = User.find_or_create_by(username: 'test_user') do |u|
  u.narrator_prompt = "You are a cyberpunk fixer. Call me runner."
end
puts "✓ Test user: #{user.username} (ID: #{user.id})"
puts

# Test 1: Set narrator voice
puts "1️⃣ Testing set_narrator_voice..."
response = call_tool('set_narrator_voice', {
  user_id: user.id,
  narrator_prompt: "You are GLaDOS from Portal. Be sarcastic."
})
puts "   Response: #{response[:result][:message]}"
puts

# Test 2: Start quest conversation
puts "2️⃣ Testing start_quest_conversation..."
response = call_tool('start_quest_conversation', {
  user_id: user.id,
  title: "Optimize database queries"
})
result = response[:result]
task_id = result[:task_id]
puts "   Task ID: #{task_id}"
puts "   Status: #{result[:status]}"
puts "   Questions: #{result[:required_questions].length}"
puts

# Test 3: Finalize quest
puts "3️⃣ Testing finalize_quest..."
response = call_tool('finalize_quest', {
  task_id: task_id,
  context: "Dashboard queries taking 8 seconds. 50k records per user.",
  objectives: [
    "Profile slow queries with EXPLAIN ANALYZE",
    "Add database indexes on frequently joined columns",
    "Implement pagination for large result sets",
    "Add query result caching layer",
    "Optimize N+1 queries in user dashboard",
    "Test performance with 50k+ record users"
  ]
})
result = response[:result]
puts "   Status: #{result[:status]}"
puts "   Objectives: #{result[:objectives].length}"
puts "   Progress: #{result[:progress]}"
puts

# Test 4: Check progress
puts "4️⃣ Testing check_progress..."
response = call_tool('check_progress', { user_id: user.id })
result = response[:result]
puts "   Level: #{result[:level]}, XP: #{result[:xp]}"
puts "   Active quests: #{result[:active_quests]}"
puts

# Test 5: Mark objective complete
puts "5️⃣ Testing mark_objective_complete..."
response = call_tool('mark_objective_complete', {
  task_id: task_id,
  objective_title: "Profile slow queries"
})
result = response[:result]
puts "   XP Awarded: +#{result[:xp_awarded]}"
puts "   Progress: #{result[:progress]}"
puts "   Level: #{result[:user_level]}"
puts

# Test 6: List active quests
puts "6️⃣ Testing list_active_quests..."
response = call_tool('list_active_quests', { user_id: user.id })
result = response[:result]
puts "   Active quests: #{result[:count]}"
result[:active_quests].each do |quest|
  puts "   - #{quest[:title]} (#{quest[:progress]})"
end
puts

# Test 7: Get quest details
puts "7️⃣ Testing get_quest_details..."
response = call_tool('get_quest_details', { task_id: task_id })
result = response[:result]
puts "   Title: #{result[:title]}"
puts "   Progress: #{result[:progress]} (#{result[:completion_percentage]}%)"
puts "   Objectives:"
result[:objectives].each do |obj|
  status_icon = obj[:status] == 'completed' ? '✓' : '☐'
  puts "     #{status_icon} #{obj[:title]}"
end
puts

# Test 8: Complete remaining objectives
puts "8️⃣ Completing remaining objectives..."
remaining = [
  "Add database indexes",
  "Implement pagination",
  "Add query result caching",
  "Optimize N+1 queries",
  "Test performance"
]

remaining.each_with_index do |obj, i|
  response = call_tool('mark_objective_complete', {
    task_id: task_id,
    objective_title: obj
  })
  if response[:error]
    puts "   ✗ Error completing '#{obj}': #{response[:error][:message]}"
  else
    result = response[:result]
    puts "   #{i+2}/6 complete (+#{result[:xp_awarded]} XP)"
  end
end
puts

# Test 9: Complete quest
puts "9️⃣ Testing complete_quest..."
response = call_tool('complete_quest', { task_id: task_id })
if response[:error]
  puts "   ✗ Error: #{response[:error][:message]}"
else
  result = response[:result]
  puts "   Bonus XP: +#{result[:xp_awarded]}"
  puts "   Total XP: #{result[:total_xp]}"
  puts "   Level: #{result[:level]}"
  puts "   Level Up: #{result[:level_up]}"
end
puts

# Test 10: Final check progress
puts "🔟 Final check_progress..."
response = call_tool('check_progress', { user_id: user.id })
result = response[:result]
puts "   Level: #{result[:level]}, XP: #{result[:xp]}/#{result[:xp] + result[:xp_to_next_level]}"
puts "   Completed quests: #{result[:completed_quests]}"
puts

puts "✅ All tool tests completed!"
